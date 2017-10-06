//
//  FirstViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hero

class MarketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var btcPriceLabel: UILabel!
    @IBOutlet var btcAmount: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var infoButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    #if LITE_VERSION
    @IBAction func upgradeButton(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/id1266256984")!)
    }
    #endif
    
    let defaults = UserDefaults.standard
    var selectedCountry: String!
    
    var currentBtcPriceString = "0"
    
    var dataValues: [Double] = []
    var btcPrices = BtcPrices()
    var markets: [Market] = []
    let numberFormatter = NumberFormatter()
    
    var currentBtcPrice: Double = 0.0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func refreshButton(_ sender: Any) {
        self.btcPriceLabel.text = currentBtcPriceString
//        self.getCurrentBtcPrice()
        self.loadData()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btcAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        let width = UIScreen.main.bounds.width
//        //        let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
//        //        print(self.collectionView.contentSize)
//        //        print(height)
//        layout.itemSize = CGSize(width: width/3, height: width/5)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        layout.headerReferenceSize = CGSize(width: width, height: width/6)
//        self.collectionView.collectionViewLayout = layout
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            present(alert, animated: true, completion: nil)
            print("here")
        }
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        if selectedCountry == "india" {
            self.numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if selectedCountry == "usa" {
            self.numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        self.isHeroEnabled = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        self.loadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.markets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let market = self.markets[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? MarketTableViewCell!
        cell!.siteLabel?.setTitle(market.title, for: .normal)
        #if PRO_VERSION
            if market.buyPrice == -1 {
                cell!.buyLabel?.text = "Coming"
                cell!.sellLabel?.text = "Soon"
            }
            else {
                cell!.buyLabel?.text = self.numberFormatter.string(from: NSNumber(value: market.buyPrice))
                cell!.sellLabel?.text = self.numberFormatter.string(from: NSNumber(value: market.sellPrice))
            }
        #endif
        #if LITE_VERSION
            if market.buyPrice == -1 {
                cell!.buyLabel?.text = "Upgrade"
                cell!.sellLabel?.text = "Required"
            }
            else {
                cell!.buyLabel?.text = self.numberFormatter.string(from: NSNumber(value: market.buyPrice))
                cell!.sellLabel?.text = self.numberFormatter.string(from: NSNumber(value: market.sellPrice))
            }
            
        #endif
        
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
//        self.btcPrices.empty()
//        self.dataValues = []
        self.markets.removeAll()
        self.activityIndicator.startAnimating()
        
        self.btcPriceLabel.text = self.currentBtcPriceString

        self.populatePrices { (success) -> Void in
            if (success) {
                #if PRO_VERSION
                    let when = DispatchTime.now() + 4
                #endif
                #if LITE_VERSION
                    let when = DispatchTime.now() + 2
                #endif
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.newPrices()
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
        self.btcAmount.text = "1"
        
//        self.collectionView.dataSource = btcPrices
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
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
    }
    
    func updateCurrentBtcPrice(_ value: Double) {
        self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: value))
    }
    
    // populate exchange buy and sell prices
    func populatePrices(completion: (_ success: Bool) -> Void) {
        #if PRO_VERSION
            if self.selectedCountry == "india" {
                self.zebpayPrice()
                self.localbitcoinsPrice()
                self.coinsecurePrice()
//                self.unocoinPrice()
                self.pocketBitsPrice()
                self.throughbitPrice()
            }
            else if self.selectedCountry == "usa" {
                self.coinbasePrice()
                self.krakenPrice()
                self.poloniexPrice()
                self.localbitcoinsUSAPrice()
                self.geminiPrice()
                self.bitfinexPrice()
                self.bitstampPrice()
            }
        #endif
        
        #if LITE_VERSION
            if self.selectedCountry == "india" {
                self.zebpayPrice()
                self.coinsecurePrice()
                self.throughbitPrice()
            }
            else if self.selectedCountry == "usa" {
                self.coinbasePrice()
                self.krakenPrice()
                self.localbitcoinsUSAPrice()
            }
        #endif
        
        completion(true)
    }

    func newPrices() {
        #if PRO_VERSION
            if self.selectedCountry == "india" {
                self.bitbayPrice()
                self.reminatoPrice()
            }
            else if self.selectedCountry == "usa" {
                
            }
        #endif
        
        #if LITE_VERSION
            if self.selectedCountry == "india" {
                self.localbitcoinsPrice()
                self.pocketBitsPrice()
            }
            else if self.selectedCountry == "usa" {
                self.geminiPrice()
                self.bitfinexPrice()
                self.bitstampPrice()
            }
        #endif
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
                    
                    self.markets.append(Market(title: "Zebpay", buyPrice: zebpaySellPrice, sellPrice: zebpayBuyPrice))
                    
                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
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
        
        #if PRO_VERSION
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
                            
                            self.markets.append(Market(title: "LocalBitcoins", buyPrice: tempBuy, sellPrice: tempSell))
                            
                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
                            }
                        }
                        else {
                            
                        }
                    }
                    sellTask.resume()
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "LocalBitcoins", buyPrice: -1, sellPrice: -1))
            
            DispatchQueue.main.async {
//                self.tableView.reloadData()
            }
        #endif
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
                    
                    self.markets.append(Market(title: "Coinsecure", buyPrice: csBuyPrice, sellPrice: csSellPrice))
                    
                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    
    // get zebpay buy and sell prices
    func pocketBitsPrice() {
        #if PRO_VERSION
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
                        
                        self.markets.append(Market(title: "PocketBits", buyPrice: pocketBitsBuyPrice, sellPrice: pocketBitsSellPrice))
                        
                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
                        }
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            
            self.markets.append(Market(title: "PocketBits", buyPrice: -1, sellPrice: -1))

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        #endif
    }
    
    func throughbitPrice() {
        #if PRO_VERSION
            let url = URL(string: "https://www.throughbit.com/tbit_ci/index.php/cryptoprice/type/btc/inr")
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
                if let tBuyPriceString = json["data"]["price"][0]["buy_price"].string {
                    if let tSellPriceString = json["data"]["price"][0]["sell_price"].string {
                        if let tBuyPrice = Double(tBuyPriceString), let tSellPrice = Double(tSellPriceString) {
                            
                            self.markets.append(Market(title: "Throughbit", buyPrice: tBuyPrice, sellPrice: tSellPrice))

                            DispatchQueue.main.async {
                                //self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            
            self.markets.append(Market(title: "Throughbit", buyPrice: -1, sellPrice: -1))

            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        #endif
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
        
        self.markets.append(Market(title: "Remitano", buyPrice: -1, sellPrice: -1))

        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
        
    }
    
    func bitbayPrice() {
        
        self.markets.append(Market(title: "BitBay", buyPrice: -1, sellPrice: -1))

        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
        
    }
    
    func coinbasePrice() {
        var cbBuyPrice: Double!, cbSellPrice: Double!
        let url = URL(string: "https://api.coinbase.com/v2/prices/BTC-USD/buy")
        let buyTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = JSON(data: data)
            if let cbBuyPriceString = json["data"]["amount"].string {
                if let price = Double(cbBuyPriceString) {
                    cbBuyPrice = price
                }
            }
            let sellUrl = URL(string: "https://api.coinbase.com/v2/prices/BTC-USD/sell")
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
                if let cbSellPriceString = json["data"]["amount"].string {
                    if let cbSellPrice = Double(cbSellPriceString) {
                        self.markets.append(Market(title: "Coinbase", buyPrice: cbBuyPrice, sellPrice: cbSellPrice))
                    }
                }
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
            }
            sellTask.resume()
        }
        buyTask.resume()
    }

    func krakenPrice() {
        let url = URL(string: "https://api.kraken.com/0/public/Ticker?pair=xbtusd")
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
            if let krakenBuyPriceString = json["result"]["XXBTZUSD"]["a"][0].string {
                if let krakenSellPriceString = json["result"]["XXBTZUSD"]["b"][0].string {
                    if let buyPrice = Double(krakenBuyPriceString), let sellPrice = Double(krakenSellPriceString) {
                        self.markets.append(Market(title: "Kraken", buyPrice: buyPrice, sellPrice: sellPrice))
                    }
                    
                }
                
            }
            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    // problem - verification page on api call prevents access
    func poloniexPrice() {
        let url = URL(string: "https://poloniex.com/public?command=returnTicker")
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
            if let pBuyPriceString = json["USDT_BTC"]["lowestAsk"].string {
                if let pSellPriceString = json["USDT_BTC"]["highestBid"].string {
                    if let buyPrice = Double(pBuyPriceString), let sellPrice = Double(pSellPriceString) {
                        
                        self.markets.append(Market(title: "Poloniex", buyPrice: buyPrice, sellPrice: sellPrice))

                    }
                    
                }
            }
            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func localbitcoinsUSAPrice() {
        
            let url = URL(string: "https://localbitcoins.com/buy-bitcoins-online/USD/.json")
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
                    
                    let sellUrl = URL(string: "https://localbitcoins.com/sell-bitcoins-online/usd/c/bank-transfers/.json")
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
                            
                            self.markets.append(Market(title: "Localbitcoins", buyPrice: tempBuy, sellPrice: tempSell))

                            DispatchQueue.main.async {
                                //self.tableView.reloadData()
                            }
                        }
                        else {
                            
                        }
                    }
                    sellTask.resume()
                    
                }
            }
            task.resume()
        
//        #if LITE_VERSION
//            self.dataValues.append(-1)
//            self.dataValues.append(-1)
//
//            self.btcPrices.add("Localbitcoins")
//            self.btcPrices.add("Upgrade")
//            self.btcPrices.add("Required")
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        #endif
    }
    
    func geminiPrice() {
        
        #if PRO_VERSION
            let url = URL(string: "https://api.gemini.com/v1/pubticker/btcusd")
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
                if let gBuyPriceString = json["ask"].string {
                    if let gSellPriceString = json["bid"].string {
                        if let buyPrice = Double(gBuyPriceString), let sellPrice = Double(gSellPriceString) {
                            self.markets.append(Market(title: "Gemini", buyPrice: buyPrice, sellPrice: sellPrice))
                        }
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Gemini", buyPrice: -1, sellPrice: -1))

            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        #endif
    }
    
    func bitfinexPrice() {
        
        #if PRO_VERSION
            let url = URL(string: "https://api.bitfinex.com/v1/pubticker/btcusd")
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
                if let gBuyPriceString = json["ask"].string {
                    if let gSellPriceString = json["bid"].string {
                        if let buyPrice = Double(gBuyPriceString), let sellPrice = Double(gSellPriceString) {
                            self.markets.append(Market(title: "Bitfinex", buyPrice: buyPrice, sellPrice: sellPrice))

                        }
                    }
                }
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Bitfinex", buyPrice: -1, sellPrice: -1))

            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        #endif
    }
    
    func bitstampPrice() {
        
        #if PRO_VERSION
            let url = URL(string: "https://www.bitstamp.net/api/ticker/")
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
                if let gBuyPriceString = json["ask"].string {
                    if let gSellPriceString = json["bid"].string {
                        if let buyPrice = Double(gBuyPriceString), let sellPrice = Double(gSellPriceString) {
                            self.markets.append(Market(title: "Bitstamp", buyPrice: buyPrice, sellPrice: sellPrice))

                        }
                    }
                }
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Bitstamp", buyPrice: -1, sellPrice: -1))

            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        #endif
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
