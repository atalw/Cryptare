//
//  FirstViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON

class FirstViewController: UIViewController {
    
    @IBOutlet var btcPriceLabel: UILabel!
    @IBOutlet var btcChange: UILabel!
    @IBOutlet var timespan: UILabel!
    
    @IBOutlet var btcAmount: UITextField!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var infoView: UIView!
    
    @IBOutlet weak var GoogleBannerView: GADBannerView!
    
    var dataValues: [Double] = []
    var btcPrices = BtcPrices()
    let numberFormatter = NumberFormatter()
    
    var currentBtcPrice: Double = 0.0
    
    @IBAction func refreshButton(_ sender: Any) {
//        self.btcPriceLabel.reloadInputViews()
        self.getCurrentBtcPrice()
        self.loadData()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btcAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        //        let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        //        print(self.collectionView.contentSize)
        //        print(height)
        layout.itemSize = CGSize(width: width/3, height: width/5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: width, height: width/6)
        self.collectionView.collectionViewLayout = layout
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            //            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            //            self.present(alert, animated: true){}
            present(alert, animated: true, completion: nil)
            print("here")
            //            alert.show()
        }
        else {
            //            print("User is connected")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        self.numberFormatter.locale = Locale.init(identifier: "en_IN")
        
        GoogleBannerView.adUnitID = "ca-app-pub-5797975753570133/6060905008"
        GoogleBannerView.rootViewController = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "4ea243399569ee090d038a5f50f2bed7"]
        
        GoogleBannerView.load(request)
        
        self.loadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        self.btcPrices.empty()
        self.dataValues = []
        
        self.getCurrentBtcPrice()
//        self.populatePrices()
        self.populatePrices { (success) -> Void in
            if (success) {
                let when = DispatchTime.now() + 4
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.newPrices()
                }
            }
        }
//        self.newPrices { (success) -> Void in
//            if (success) {
//                let when = DispatchTime.now() + 2
//                DispatchQueue.main.asyncAfter(deadline: when) {
//                    self.populatePrices()
//                }
//            }
//        }
        
        self.btcAmount.text = "1"
        
        self.collectionView.dataSource = btcPrices
    }
    
    func infoButtonTapped() {
    
        UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: { _ in
            self.infoView.isHidden = false
        }, completion: nil)

//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//            self.infoView.isHidden = false
//        })
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
        if let value = Double(text!) {
            if value > 200 {
                textField.text = "Aukat"
            }
            else if value > 0 {
                let updatedValue = self.currentBtcPrice*value
                self.updateCurrentBtcPrice(updatedValue)
                
                var count = 3
                var dataValuesIndex = 0
                for (index, _) in self.btcPrices.getItems().enumerated() {
                    if count <= 2  && count > 0 {
                        let cost = self.dataValues[dataValuesIndex]
                        dataValuesIndex += 1
                        if cost >= 0 {
                            let updatedValue = cost * value
                            let updatedValueString = self.numberFormatter.string(from: NSNumber(value: updatedValue))
                            self.btcPrices.updateItems(updatedValueString!, index: index)
                        }
                    }
                    else if count == 0 {
                        count = 2
                        continue
                    }
                    count -= 1
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        //        else {
        //            print("empty")
        //        }
    }
    
    func updateCurrentBtcPrice(_ value: Double) {
        self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: value))
    }
    
    func getNumberFromCommaString(_ stringNumber: String) -> Double {
        let numberWithoutComma = stringNumber.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil)
        let numberWithoutSymbol = numberWithoutComma.replacingOccurrences(of: "₹ ", with: "", options: NSString.CompareOptions.literal, range: nil)
        return Double(numberWithoutSymbol)!
    }
    
    // get current actual price of bitcoin
    func getCurrentBtcPrice() {
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/INR.json")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = JSON(data: data)
            if let priceString = json["bpi"]["INR"]["rate"].string {
                let priceWithoutComma = priceString.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range:nil)
                let price = Double(priceWithoutComma)
                self.currentBtcPrice = price!
                self.getHistoricalBtcPrices(price!)
                DispatchQueue.main.async {
                    self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: price!))
                    self.btcPriceLabel.textColor = UIColor.white
                    self.btcPriceLabel.adjustsFontSizeToFitWidth = true
                    self.timespan.text = "(24h)"
                    self.timespan.textColor = UIColor.white
                }
            }
            else {
                print(json["bpi"]["INR"]["rate"].error!)
            }
        }
        task.resume()
    }
    
    // used to calculate percentage change over 24h period (add functionality to change timespan)
    func getHistoricalBtcPrices(_ currentBtcPrice: Double) {
        let current_date = Date()
        let yesterday_date = Calendar.current.date(byAdding: .day, value: -1, to: current_date)!
        // sometimes takes time for source website to update closing price of day before (probably due to time difference)
        let day_before_yesterday_date = Calendar.current.date(byAdding: .day, value: -2, to: current_date)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = formatter.string(from: yesterday_date)
        let day_before_yesterday = formatter.string(from: day_before_yesterday_date)
        
        
        let url = URL(string: "http://api.coindesk.com/v1/bpi/historical/close.json?currency=INR")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let inrPrice = json?["bpi"] as? [String: Any]
                let yesterdayBtcPrice = inrPrice?[yesterday] as? Double ?? inrPrice?[day_before_yesterday] as? Double
                let change = currentBtcPrice - yesterdayBtcPrice!
                let percentage = change/yesterdayBtcPrice! * 100
                let roundedPercentage = Double(round(100*percentage)/100)
                DispatchQueue.main.async {
                    if roundedPercentage > 0 {
                        self.btcChange.text = "+\(roundedPercentage)%"
                    }
                    else {
                        self.btcChange.text = "\(roundedPercentage)%"
                    }
                    self.btcChange.layer.masksToBounds = true
                    self.btcChange.layer.cornerRadius = 8
                    self.btcChange.textColor = UIColor.white
                    if roundedPercentage < 0 {
                        self.btcChange.backgroundColor = self.hexStringToUIColor(hex: "#e74c3c")
                    }
                    else if roundedPercentage > 0 {
                        self.btcChange.backgroundColor = self.hexStringToUIColor(hex: "#2ecc71")
                    }
                    
                }

            }
            catch {
                print("Error")
            }
                    }
        task.resume()
        
    }
    
    // populate exchange buy and sell prices
    func populatePrices(completion: (_ success: Bool) -> Void) {
        self.zebpayPrice()
        self.localbitcoinsPrice()
        self.coinsecurePrice()
        self.unocoinPrice()
        self.pocketBitsPrice()
        completion(true)
    }

    func newPrices() {
        self.bitbayPrice()
        self.reminatoPrice()
    }
    
    // get zebpay buy and sell prices
    func zebpayPrice() {
        let url = URL(string: "https://api.zebpay.com/api/v1/ticker?currencyCode=INR")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = JSON(data: data)
            if let zebpayBuyPrice = json["buy"].double {
                if let zebpaySellPrice = json["sell"].double {
                    self.dataValues.append(zebpayBuyPrice)
                    self.dataValues.append(zebpaySellPrice)
                    
                    let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: zebpayBuyPrice))
                    let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: zebpaySellPrice))
                    
                    self.btcPrices.add("Zebpay")
                    self.btcPrices.add(formattedBuyPrice!)
                    self.btcPrices.add(formattedSellPrice!)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                else {
                    print(json["buy"].error!)
                }
            }
        }
        task.resume()
    }
    
    // get unocoin buy and sell prices
    func unocoinPrice() {
        //        let urlBuy = URL(string: "https://www.unocoin.com/trade.php?buy")
        //        let taskBuy = URLSession.shared.dataTask(with: urlBuy!) { data, response, error in
        //            guard error == nil else {
        //                print(error!)
        //                return
        //            }
        //            guard let data = data else {
        //                print("Data is empty")
        //                return
        //            }
        //            print(data)
        //            let buyData = String(data: data, encoding: String.Encoding.utf8)
        ////            let encodedData =
        ////            let buyData = try! JSONSerialization.jsonObject(with: ) as? Double
        //            print(buyData)
        //
        //
        //        }
        //        taskBuy.resume()
        
        //        let urlSell = URL(string: "https://www.unocoin.com/trade.php?sell")
        //        let taskSell = URLSession.shared.dataTask(with: urlSell!) { data, response, error in
        //            guard error == nil else {
        //                print(error!)
        //                return
        //            }
        //            guard let data = data else {
        //                print("Data is empty")
        //                return
        //            }
        //        }
        //        taskSell.resume()

        
        let url = URL(string: "https://www.unocoin.com/trade.php?all")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let unocoinBuyPrice = json?["buy"] as? Double
                let unocoinSellPrice = json?["sell"] as? Double
                
                self.dataValues.append(unocoinBuyPrice!)
                self.dataValues.append(unocoinSellPrice!)
                
                let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: unocoinBuyPrice!))
                let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: unocoinSellPrice!))
                
                self.btcPrices.add("Unocoin")
                self.btcPrices.add(formattedBuyPrice!)
                self.btcPrices.add(formattedSellPrice!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            catch {
//                print(data)
            }
        }
        task.resume()
    }
    
    // get localbitcoin buy and sell prices
    func localbitcoinsPrice() {
        let url = URL(string: "https://localbitcoins.com/buy-bitcoins-online/INR/.json")
        var tempBuy: Double = 0.0
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = JSON(data: data)
            if let z = json["data"]["ad_list"][0]["data"]["temp_price"].string {
                tempBuy = Double(z)!
                
                self.dataValues.append(tempBuy)
                
                let sellUrl = URL(string: "https://localbitcoins.com/sell-bitcoins-online/INR/.json")
                let sellTask = URLSession.shared.dataTask(with: sellUrl!) { data, response, error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    guard let data = data else {
                        print("Data is empty")
                        return
                    }
                    
                    let json = JSON(data: data)
                    if let z = json["data"]["ad_list"][0]["data"]["temp_price"].string {
                        let tempSell = Double(z)!
                        
                        self.dataValues.append(tempSell)
                        
                        let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: tempBuy))
                        let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: tempSell))
                        
                        self.btcPrices.add("Localbitcoins")
                        self.btcPrices.add(formattedBuyPrice!)
                        self.btcPrices.add(formattedSellPrice!)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    else {
                        
                    }
                }
                sellTask.resume()
                
            }
        }
        task.resume()
    }

    // get coinsecure buy and sell prices
    func coinsecurePrice() {
        let url = URL(string: "https://api.coinsecure.in/v1/exchange/ticker")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = JSON(data: data)
            if var csBuyPrice = json["message"]["ask"].double {
                if var csSellPrice = json["message"]["lastPrice"].double {
                    csBuyPrice = csBuyPrice/100
                    csSellPrice = csSellPrice/100
                    
                    self.dataValues.append(csBuyPrice)
                    self.dataValues.append(csSellPrice)
                    
                    let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: csBuyPrice))
                    let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: csSellPrice))
                    
                    self.btcPrices.add("Coinsecure")
                    self.btcPrices.add(formattedBuyPrice!)
                    self.btcPrices.add(formattedSellPrice!)
                    
                }
                else {
                    
                }
            }
            else {
                
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
        task.resume()
    }
    
    // get zebpay buy and sell prices
    func pocketBitsPrice() {
        let url = URL(string: "https://www.pocketbits.in/Index/getBalanceRates")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = JSON(data: data)
            if let pocketBitsBuyPrice = json["rates"]["BTC_BuyingRate"].double {
                if let pocketBitsSellPrice = json["rates"]["BTC_SellingRate"].double {
                    self.dataValues.append(pocketBitsBuyPrice)
                    self.dataValues.append(pocketBitsSellPrice)
                    
                    let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: pocketBitsBuyPrice))
                    let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: pocketBitsSellPrice))
                    
                    self.btcPrices.add("PocketBits")
                    self.btcPrices.add(formattedBuyPrice!)
                    self.btcPrices.add(formattedSellPrice!)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                else {
                    print(json["buy"].error!)
                }
            }
        }
        task.resume()
    }

    
//    // get remitano buy and sell prices
//    func remitanoPrice() {
//        let url = URL(string: "https://www.unocoin.com/trade?all")
//        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//            guard let data = data else {
//                print("Data is empty")
//                return
//            }
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                let unocoinBuyPrice = json?["buy"] as? Double
//                let unocoinSellPrice = json?["sell"] as? Double
//                
//                self.dataValues.append(unocoinBuyPrice!)
//                self.dataValues.append(unocoinSellPrice!)
//                
//                let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: unocoinBuyPrice!))
//                let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: unocoinSellPrice!))
//                
//                self.btcPrices.add("Remitano")
//                self.btcPrices.add(formattedBuyPrice!)
//                self.btcPrices.add(formattedSellPrice!)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//            catch {
//                print(data)
//            }
//            
//            
//        }
//        task.resume()
//    }

    func reminatoPrice() {
        
        self.dataValues.append(-1)
        self.dataValues.append(-1)
        
        self.btcPrices.add("Remitano")
        self.btcPrices.add("Coming Soon")
        self.btcPrices.add("Coming Soon")
        
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func bitbayPrice() {
        
        self.dataValues.append(-1)
        self.dataValues.append(-1)
        
        self.btcPrices.add("BitBay")
        self.btcPrices.add("Coming Soon")
        self.btcPrices.add("Coming Soon")
        
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }

    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

