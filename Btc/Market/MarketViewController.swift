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
    @IBOutlet var infoButton: UIBarButtonItem!
    
    @IBOutlet weak var buySortButton: UIButton!
    @IBOutlet weak var sellSortButton: UIButton!
    
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
    var copyMarkets: [(Double, Double)] = []
    let numberFormatter = NumberFormatter()
    
    var currentBtcPrice: Double = 0.0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var buySortButtonCounter = 0
    var sellSortButtonCounter = 0
    
    let buyTitleArray = ["Buy", "Buy ▲", "Buy ▼"]
    let sellTitleArray = ["Sell", "Sell ▲", "Sell ▼"]
    
    @IBAction func refreshButton(_ sender: Any) {
        self.btcPriceLabel.text = currentBtcPriceString
        self.loadData()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            present(alert, animated: true, completion: nil)
            print("here")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.btcAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        
        buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
        self.buySortButton.addTarget(self, action: #selector(buySortButtonTapped), for: .touchUpInside)
        
        sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
        self.sellSortButton.addTarget(self, action: #selector(sellSortButtonTapped), for: .touchUpInside)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        activityIndicator.center = self.tableView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.tableView.addSubview(activityIndicator)
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }
    
    @objc func buySortButtonTapped() {
        buySortButtonCounter = (buySortButtonCounter + 1) % buyTitleArray.count
        if buySortButtonCounter == 0 {
            buySortButtonCounter = 1
        }
        if buySortButtonCounter == 1 {
            self.markets.sort(by: {$0.buyPrice < $1.buyPrice})
            self.copyMarkets.sort(by: {$0.0 < $1.0})
        }
        else if buySortButtonCounter == 2 {
            self.markets.sort(by: {$0.buyPrice > $1.buyPrice})
            self.copyMarkets.sort(by: {$0.0 > $1.0})
        }
        buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
        sellSortButtonCounter = 0
        sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
        tableView.reloadData()
    }
    
    @objc func sellSortButtonTapped() {
        sellSortButtonCounter = (sellSortButtonCounter + 1) % sellTitleArray.count
        if sellSortButtonCounter == 0 {
            sellSortButtonCounter = 1
        }
        if sellSortButtonCounter == 1 {
            self.markets.sort(by: {$0.sellPrice < $1.sellPrice})
            self.copyMarkets.sort(by: {$0.1 < $1.1})
        }
        else if sellSortButtonCounter == 2 {
            self.markets.sort(by: {$0.sellPrice > $1.sellPrice})
            self.copyMarkets.sort(by: {$0.1 > $1.1})
        }
        sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
        buySortButtonCounter = 0
        buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
        tableView.reloadData()
    }
    
    @objc func handleButton(sender: CustomUIButton!) {
        if let link = sender.url {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(link)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.markets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let market = self.markets[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? MarketTableViewCell!
        cell!.siteLabel?.setTitle(market.title, for: .normal)
        cell!.siteLabel.url = market.siteLink
        cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        
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
        self.markets.removeAll()
        self.copyMarkets.removeAll()
        self.tableView.reloadData()
        self.activityIndicator.startAnimating()
        
        self.currentBtcPrice = GlobalValues.currentBtcPrice
        self.currentBtcPriceString = GlobalValues.currentBtcPriceString
        
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
                    #if LITE_VERSION
                        self.newPrices()
                    #endif
                    self.activityIndicator.stopAnimating()
                    // Default to ascending Buy prices
                    self.defaultSort()
                }
            }
        }
        self.btcAmount.text = "1"
    }
    
    func defaultSort() {
        let marketSort = defaults.string(forKey: "marketSort")
        let marketOrder = defaults.string(forKey: "marketOrder")
        
        self.buySortButtonCounter = 0
        self.sellSortButtonCounter = 0
        
        if marketSort == "buy" {
            if marketOrder == "ascending" {
                self.buySortButton.sendActions(for: .touchUpInside)
            }
            else if marketOrder == "descending" {
                self.buySortButton.sendActions(for: .touchUpInside)
                self.buySortButton.sendActions(for: .touchUpInside)
            }
        }
        else if marketSort == "sell" {
            if marketOrder == "ascending" {
                self.sellSortButton.sendActions(for: .touchUpInside)
            }
            else if marketOrder == "descending" {
                self.sellSortButton.sendActions(for: .touchUpInside)
                self.sellSortButton.sendActions(for: .touchUpInside)
            }
        }
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
                
                for index in 0..<self.copyMarkets.count {
                    self.markets[index].buyPrice = self.copyMarkets[index].0 * value
                    self.markets[index].sellPrice = self.copyMarkets[index].1 * value
                }
            }
            self.tableView.reloadData()
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
                self.unocoinPrice()
                self.pocketBitsPrice()
                self.throughbitPrice()
                self.koinexPrice()
            }
            else if self.selectedCountry == "usa" {
                self.coinbasePrice()
                self.krakenPrice()
                self.poloniexPrice()
                self.localbitcoinsUSAPrice()
                self.geminiPrice()
                self.bitfinexPrice()
                self.bitstampPrice()
                self.bittrexPrice()
            }
        #endif
        
        #if LITE_VERSION
            if self.selectedCountry == "india" {
                self.zebpayPrice()
                self.coinsecurePrice()
                self.unocoinPrice()
                self.koinexPrice()
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
                self.throughbitPrice()
            }
            else if self.selectedCountry == "usa" {
                self.geminiPrice()
                self.bitfinexPrice()
                self.bitstampPrice()
                self.bittrexPrice()
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
                    
                    self.markets.append(Market(title: "Zebpay", siteLink: URL(string: "https://www.zebpay.com/?utm_campaign=app_refferal_ref/ref/REF34005162&utm_medium=app&utm_source=zebpay_app_refferal"), buyPrice: zebpayBuyPrice, sellPrice: zebpaySellPrice))
                    self.copyMarkets.append((zebpayBuyPrice, zebpaySellPrice))
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
        let url = URL(string: "https://www.unocoin.com/trade.php?all")
        var mutableURLRequest = NSMutableURLRequest(url: url!)
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.addValue("application/json", forHTTPHeaderField: "Accept")

//        mutableURLRequest.addValue("<#T##value: String##String#>", forHTTPHeaderField: "Authorization: Bearer ")
        let task = URLSession.shared.dataTask(with: mutableURLRequest as URLRequest) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            print("outside")

            let json = JSON(data: data)
            print(json)
            if let buyPrice = json["buy"].int {
                print("here")
                if let sellPrice = json["sell"].int {
                    self.markets.append(Market(title: "Unocoin", siteLink: URL(string: "https://www.unocoin.com/?referrerid=301527"), buyPrice: Double(buyPrice), sellPrice: Double(sellPrice)))
                    self.copyMarkets.append((Double(buyPrice), Double(sellPrice)))
                }
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
                            
                            self.markets.append(Market(title: "LocalBitcoins", siteLink: URL(string: "https://localbitcoins.com/?ch=cynk"), buyPrice: tempBuy, sellPrice: tempSell))
                            
                            self.copyMarkets.append((tempBuy, tempSell))
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
            self.markets.append(Market(title: "LocalBitcoins", siteLink: URL(string: "https://localbitcoins.com/?ch=cynk"), buyPrice: -1, sellPrice: -1))
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
            if var csBuyPrice = json["message"]["bid"].double {
                if var csSellPrice = json["message"]["ask"].double {
                    csBuyPrice = csBuyPrice/100
                    csSellPrice = csSellPrice/100
                    
                    self.markets.append(Market(title: "Coinsecure", siteLink: URL(string: "https://coinsecure.in/signup/TVRWPVbGFVx7nYcr6YYM"), buyPrice: csBuyPrice, sellPrice: csSellPrice))
                    self.copyMarkets.append((csBuyPrice, csSellPrice))

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
                        
                        self.markets.append(Market(title: "PocketBits", siteLink: URL(string: "https://www.pocketbits.in/"), buyPrice: pocketBitsBuyPrice, sellPrice: pocketBitsSellPrice))
                        self.copyMarkets.append((pocketBitsBuyPrice, pocketBitsSellPrice))

                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "PocketBits", siteLink: URL(string: "https://www.pocketbits.in/"), buyPrice: -1, sellPrice: -1))
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
                            
                            self.markets.append(Market(title: "Throughbit", siteLink: URL(string: "https://www.throughbit.com/"), buyPrice: tBuyPrice, sellPrice: tSellPrice))
                             self.copyMarkets.append((tBuyPrice, tSellPrice))
                        }
                        
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Throughbit", siteLink: URL(string: "https://www.throughbit.com/"), buyPrice: -1, sellPrice: -1))
        #endif
    }
    
    func koinexPrice() {
        #if PRO_VERSION
            let url = URL(string: "https://koinex.in/api/ticker")
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
                if let tBuyPriceString = json["stats"]["BTC"]["highest_bid"].string {
                    if let tSellPriceString = json["stats"]["BTC"]["lowest_ask"].string {
                        if let tBuyPrice = Double(tBuyPriceString), let tSellPrice = Double(tSellPriceString) {
                            
                            self.markets.append(Market(title: "Koinex", siteLink: URL(string: "https://koinex.in/?ref=8271af"), buyPrice: tBuyPrice, sellPrice: tSellPrice))
                            self.copyMarkets.append((tBuyPrice, tSellPrice))

                        }
                        
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Throughbit", siteLink: URL(string: "https://www.throughbit.com/"), buyPrice: -1, sellPrice: -1))
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
        
        self.markets.append(Market(title: "Remitano", siteLink: URL(string: "https://remitano.com/in?ref=atalw"), buyPrice: -1, sellPrice: -1))
    }
    
    func bitbayPrice() {
        
        self.markets.append(Market(title: "BitBay", siteLink: URL(string: "https://auth.bitbay.net/ref/atalw"), buyPrice: -1, sellPrice: -1))
    }
    
    func coinbasePrice() {
        var cbBuyPrice: Double!
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
                        self.markets.append(Market(title: "Coinbase", siteLink: URL(string: "https://www.coinbase.com/join/57f5a4bef3a4f2006d0b7f4b"), buyPrice: cbBuyPrice, sellPrice: cbSellPrice))
                        self.copyMarkets.append((cbBuyPrice, cbSellPrice))

                    }
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
                        self.markets.append(Market(title: "Kraken", siteLink: URL(string: "https://www.kraken.com/"), buyPrice: buyPrice, sellPrice: sellPrice))
                        self.copyMarkets.append((buyPrice, sellPrice))

                    }
                    
                }
                
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
                        // change to poloniex URL
                        self.markets.append(Market(title: "Poloniex", siteLink: URL(string: "https://www.kraken.com/"), buyPrice: buyPrice, sellPrice: sellPrice))
                        self.copyMarkets.append((buyPrice, sellPrice))


                    }
                    
                }
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
                            
                            self.markets.append(Market(title: "Localbitcoins", siteLink: URL(string: "https://localbitcoins.com/?ch=cynk"), buyPrice: tempBuy, sellPrice: tempSell))
                            self.copyMarkets.append((tempBuy, tempSell))

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
                if let gBuyPriceString = json["bid"].string {
                    if let gSellPriceString = json["ask"].string {
                        if let buyPrice = Double(gBuyPriceString), let sellPrice = Double(gSellPriceString) {
                            self.markets.append(Market(title: "Gemini", siteLink: URL(string: "https://gemini.com/"), buyPrice: buyPrice, sellPrice: sellPrice))
                            self.copyMarkets.append((buyPrice, sellPrice))

                        }
                        
                    }
                    
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Gemini", siteLink: URL(string: "https://gemini.com/"), buyPrice: -1, sellPrice: -1))
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
                if let gBuyPriceString = json["bid"].string {
                    if let gSellPriceString = json["ask"].string {
                        if let buyPrice = Double(gBuyPriceString), let sellPrice = Double(gSellPriceString) {
                            self.markets.append(Market(title: "Bitfinex", siteLink: URL(string: "https://www.bitfinex.com/"), buyPrice: buyPrice, sellPrice: sellPrice))
                            self.copyMarkets.append((buyPrice, sellPrice))

                        }
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Bitfinex", siteLink: URL(string: "https://www.bitfinex.com/"), buyPrice: -1, sellPrice: -1))
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
                            self.markets.append(Market(title: "Bitstamp", siteLink: URL(string: "https://www.bitstamp.net/"), buyPrice: buyPrice, sellPrice: sellPrice))
                            self.copyMarkets.append((buyPrice, sellPrice))
                        }
                    }
                }
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Bitstamp", siteLink: URL(string: "https://www.bitstamp.net/"), buyPrice: -1, sellPrice: -1))
        #endif
    }
    
    func bittrexPrice() {
        
        #if PRO_VERSION
            let url = URL(string: "https://bittrex.com/api/v1.1/public/getticker?market=USDT-BTC")
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
                if json["success"].bool == true {
                    if let buyPrice = json["result"]["Bid"].double {
                        if let sellPrice = json["result"]["Ask"].double {
                            self.markets.append(Market(title: "Bittrex", siteLink: URL(string: "https://bittrex.com/"), buyPrice: buyPrice, sellPrice: sellPrice))
                            self.copyMarkets.append((buyPrice, sellPrice))
                        }
                    }
                }
                
            }
            task.resume()
        #endif
        
        #if LITE_VERSION
            self.markets.append(Market(title: "Bitstamp", siteLink: URL(string: "https://www.bitstamp.net/"), buyPrice: -1, sellPrice: -1))
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
