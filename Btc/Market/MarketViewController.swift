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
import Firebase

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
    let numberFormatter = NumberFormatter()

    var selectedCountry: String!
    
    var currentBtcPriceString = "0"
    var currentBtcPrice: Double = 0.0

    var textFieldValue = 1.0

    var buySortButtonCounter = 0
    var sellSortButtonCounter = 0
    
    let buyTitleArray = ["Buy", "Buy ▲", "Buy ▼"]
    let sellTitleArray = ["Sell", "Sell ▲", "Sell ▼"]
    
    var markets: [Market] = []
    var copyMarkets: [(Double, Double)] = []
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: Firebase database references
    
    var zebpayRef: DatabaseReference!
    var localbitcoinsRef: DatabaseReference!
    var coinsecureRef: DatabaseReference!
    var pocketBitsRef: DatabaseReference!
    var koinexRef: DatabaseReference!
    var throughbitRef: DatabaseReference!
    
    var coinbaseRef: DatabaseReference!
    var krakenRef: DatabaseReference!
    var poloniexRef: DatabaseReference!
    var geminiRef: DatabaseReference!
    var bitfinexRef: DatabaseReference!
    var bitstampRef: DatabaseReference!
    var bittrexRef: DatabaseReference!

    var databaseReference: DatabaseReference!
    
    @IBAction func refreshButton(_ sender: Any) {
        self.btcPriceLabel.text = currentBtcPriceString
        self.loadData()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.btcAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        
        databaseReference = Database.database().reference()
        
        if self.defaults.string(forKey: "selectedCountry") == "india" {
            zebpayRef = databaseReference.child("zebpay")
            localbitcoinsRef = databaseReference.child("localbitcoins_BTC_\(GlobalValues.currency!)")
            coinsecureRef = databaseReference.child("coinsecure")
            pocketBitsRef = databaseReference.child("pocketbits")
            koinexRef = databaseReference.child("koinex_BTC_INR")
            throughbitRef = databaseReference.child("throughbit_BTC_INR")
        }
        else if self.defaults.string(forKey: "selectedCountry") == "usa" {
            coinbaseRef = databaseReference.child("coinbase_BTC_USD")
            krakenRef = databaseReference.child("kraken_BTC_USD")
            localbitcoinsRef = databaseReference.child("localbitcoins_BTC_USD")
//            poloniexRef = databaseReference.child("")
            geminiRef = databaseReference.child("gemini_BTC_USD")
            bitfinexRef = databaseReference.child("bitfinex_BTC_USD")
            bitstampRef = databaseReference.child("bitstamp_BTC_USD")
//            bittrexRef = databaseReference.child("")
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        if selectedCountry == "india" {
            self.numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if selectedCountry == "usa" {
            self.numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        textFieldValue = 1.0
        
        if selectedCountry == "india" {
            zebpayRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Zebpay")
                }
            })
            
            localbitcoinsRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "LocalBitcoins")
                }
            })
            
            coinsecureRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Coinsecure")
                }
            })
            
            pocketBitsRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "PocketBits")
                }
            })
            
            koinexRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Koinex")
                }
            })
            
            throughbitRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Throughbit")
                }
            })
        }
        
        else if selectedCountry == "usa" {
            coinbaseRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Coinbase")
                }
            })
            
            localbitcoinsRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "LocalBitcoins")
                }
            })
            
            krakenRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Kraken")
                }
            })
            geminiRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Gemini")
                }
            })
            bitfinexRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Bitfinex")
                }
            })
            bitstampRef.observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Bitstamp")
                }
            })
        }
        
    }
    
    func updateFirebaseObservedData(dict: [String: AnyObject], title: String) {
        
        let currentBuyPrice = dict["buy_price"] as! Double
        let currentSellPrice = dict["sell_price"] as! Double
        
        if let index = self.markets.index(where: {$0.title == title}) {
            self.markets[index].buyPrice = currentBuyPrice * self.textFieldValue
            self.markets[index].sellPrice = currentSellPrice * self.textFieldValue
            
            // update other array
            self.copyMarkets[index].0 = currentBuyPrice
            self.copyMarkets[index].1 = currentSellPrice
            
            self.tableView.reloadData()
            self.reSort()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            present(alert, animated: true, completion: nil)
            print("here")
        }
        
        self.loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if selectedCountry == "india" {
            zebpayRef.removeAllObservers()
            localbitcoinsRef.removeAllObservers()
            pocketBitsRef.removeAllObservers()
            coinsecureRef.removeAllObservers()
            koinexRef.removeAllObservers()
            throughbitRef.removeAllObservers()
        }
        else if selectedCountry == "usa" {
            coinbaseRef.removeAllObservers()
            localbitcoinsRef.removeAllObservers()
            krakenRef.removeAllObservers()
            geminiRef.removeAllObservers()
            bitfinexRef.removeAllObservers()
            bitstampRef.removeAllObservers()
        }
        
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
    
    func loadData() {
        self.markets.removeAll()
        self.copyMarkets.removeAll()
        self.tableView.reloadData()
        
        self.currentBtcPrice = GlobalValues.currentBtcPrice
        self.currentBtcPriceString = GlobalValues.currentBtcPriceString
        
        self.btcPriceLabel.text = self.currentBtcPriceString

        self.populateTable()
        self.defaultSort()
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
    
    func reSort() {
        let buySortButtonCounter = self.buySortButtonCounter
        let sellSortButtonCounter =  self.sellSortButtonCounter
        
        self.buySortButtonCounter = 0
        self.sellSortButtonCounter = 0
        
        if buySortButtonCounter == 0 {
            if sellSortButtonCounter == 1 {
                self.sellSortButton.sendActions(for: .touchUpInside)
            }
            else if sellSortButtonCounter == 2 {
                self.sellSortButton.sendActions(for: .touchUpInside)
                self.sellSortButton.sendActions(for: .touchUpInside)
            }
        }
        else if sellSortButtonCounter == 0 {
            if buySortButtonCounter == 1 {
                self.buySortButton.sendActions(for: .touchUpInside)
            }
            else if buySortButtonCounter == 2 {
                self.buySortButton.sendActions(for: .touchUpInside)
                self.buySortButton.sendActions(for: .touchUpInside)
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
                textFieldValue = value
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
    
    func populateTable() {
        if self.selectedCountry == "india" {
            // Zebpay
            addExchangeToTable(title: "Zebpay", url: "https://www.zebpay.com/?utm_campaign=app_refferal_ref/ref/REF34005162&utm_medium=app&utm_source=zebpay_app_refferal")
            
            // Unocoin
//            addExchangeToTable(title: "Unocoin", url: "https://www.unocoin.com/?referrerid=301527")
            
            // LocalBitcoins
            addExchangeToTable(title: "LocalBitcoins", url: "https://localbitcoins.com/?ch=cynk")
            
            //Coinsecure
            addExchangeToTable(title: "Coinsecure", url: "https://coinsecure.in/signup/TVRWPVbGFVx7nYcr6YYM")
            
            // Koinex
            addExchangeToTable(title: "Koinex", url: "https://koinex.in/?ref=8271af")
            
            // PocketBits
            addExchangeToTable(title: "PocketBits", url: "https://www.pocketbits.in/")
            
            // Throughbit
            addExchangeToTable(title: "Throughbit", url: "https://www.throughbit.com/")
            
        }
        else if self.selectedCountry == "usa" {
            // Coinbase
            addExchangeToTable(title: "Coinbase", url: "https://www.coinbase.com/join/57f5a4bef3a4f2006d0b7f4b")

            
            // Kraken
            addExchangeToTable(title: "Kraken", url: "https://www.kraken.com/")

            
            // Poloniex
//            addExchangeToTable(title: "Poloniex", url: "https://poloniex.com/")

            
            // LocalBitcoins
            addExchangeToTable(title: "LocalBitcoins", url: "https://localbitcoins.com/?ch=cynk")

            
            // Gemini
            addExchangeToTable(title: "Gemini", url: "https://gemini.com/")

            
            // Bitfinex
            addExchangeToTable(title: "Bitfinex", url: "https://www.bitfinex.com/")

            
            // Bitstamp
            addExchangeToTable(title: "Bitstamp", url: "https://www.bitstamp.net/")

            
            // Bittrex
//            addExchangeToTable(title: "Bittrex", url: "https://bittrex.com/")

        }
        
    }
    
    func addExchangeToTable(title: String, url: String) {
        self.markets.append(Market(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0))
        self.copyMarkets.append((0, 0))
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
