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

class MarketViewController: UIViewController {
    
    
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
    var currentBtcPrice: Double = 0.0

    var textFieldValue = 1.0

    var buySortButtonCounter = 0
    var sellSortButtonCounter = 0
    
    let buyTitleArray = ["Buy", "Buy ▲", "Buy ▼"]
    let sellTitleArray = ["Sell", "Sell ▲", "Sell ▼"]
    
    var markets: [Market] = []
    var liteMarkets : [(String, String)] = []
    var copyMarkets: [(Double, Double)] = []
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: Firebase database references
    
    var currentBtcRef: DatabaseReference!
    
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
    let databaseTitles = ["Zebpay": "zebpay", "LocalBitcoins": "localbitcoins_BTC_\(GlobalValues.currency)", "Coinsecure": "coinsecure", "PocketBits": "pocketbits", "Koinex": "koinex_BTC_INR", "Throughbit": "throughbit_BTC_INR"]
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var changedCell = -1
    var newBuyPriceIsGreater: Bool? = true
    var newSellPriceIsGreater: Bool? = true
    
    var selectedMarket: String!
    
    @IBAction func refreshButton(_ sender: Any) {
        self.btcPriceLabel.text = currentBtcPriceString
        self.loadData()
        self.tableView.reloadData()
    }
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        view.addGestureRecognizer(tap)
        
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
        
        // for current bitcoin price
        let tableTitle = "current_btc_price_\(GlobalValues.currency!)"
        currentBtcRef = Database.database().reference().child(tableTitle)
        
        currentBtcRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                let oldBtcPrice = self.currentBtcPrice
                self.currentBtcPrice = dict["price"] as! Double
                let unixTime = dict["timestamp"] as! Double
                var colour: UIColor
                
                if self.currentBtcPrice > oldBtcPrice {
                    colour = self.greenColour
                }
                else if self.currentBtcPrice < oldBtcPrice {
                    colour = self.redColour
                }
                else {
                    colour = UIColor.black
                }
                
                GlobalValues.currentBtcPriceString = self.currentBtcPrice.asCurrency
                GlobalValues.currentBtcPrice = self.currentBtcPrice
                DispatchQueue.main.async {
                    self.btcPriceLabel.text = (self.currentBtcPrice * self.textFieldValue).asCurrency
                    
                    UILabel.transition(with: self.btcPriceLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
                        self.btcPriceLabel.textColor = colour
                    }, completion: { finished in
                        UILabel.transition(with: self.btcPriceLabel, duration: 1.5, options: .transitionCrossDissolve, animations: {
                            self.btcPriceLabel.textColor = UIColor.black
                        }, completion: nil)
                    })
                    
//                    self.dateFormatter.dateFormat = "h:mm a"
//                    self.lastUpdated.text = self.dateFormatter.string(from: Date(timeIntervalSince1970: unixTime))
                }
            }
        })
        
        
        textFieldValue = 1.0
        
        if selectedCountry == "india" {
            
            zebpayRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Zebpay")
                }
            })
            
            coinsecureRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Coinsecure")
                }
            })
            
            koinexRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Koinex")
                }
            })
            
            #if PRO_VERSION
                
                localbitcoinsRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "LocalBitcoins")
                    }
                })
                
                pocketBitsRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "PocketBits")
                    }
                })
                
                throughbitRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "Throughbit")
                    }
                })
            #endif
            
        }
        
        else if selectedCountry == "usa" {
            
            coinbaseRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Coinbase")
                }
            })
            
            localbitcoinsRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "LocalBitcoins")
                }
            })
            
            krakenRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: "Kraken")
                }
            })
            
            #if PRO_VERSION
                geminiRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "Gemini")
                    }
                })
                bitfinexRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "Bitfinex")
                    }
                })
                bitstampRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedData(dict: dict, title: "Bitstamp")
                    }
                })
            #endif
            
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
        
        currentBtcRef.removeAllObservers()
        
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
    
    // MARK: Firebase helper functions
    
    func updateFirebaseObservedData(dict: [String: AnyObject], title: String) {
        
        let currentBuyPrice = dict["buy_price"] as! Double
        let currentSellPrice = dict["sell_price"] as! Double
        
        if let index = self.markets.index(where: {$0.title == title}) {
            
            let oldBuyPrice = self.copyMarkets[index].0
            let oldSellPrice = self.copyMarkets[index].1
            
            self.markets[index].buyPrice = currentBuyPrice * self.textFieldValue
            self.markets[index].sellPrice = currentSellPrice * self.textFieldValue
            
            // update other array
            self.copyMarkets[index].0 = currentBuyPrice
            self.copyMarkets[index].1 = currentSellPrice
            
            if oldBuyPrice < currentBuyPrice {
                newBuyPriceIsGreater = true
                changedCell = index
            }
            else if oldBuyPrice > currentBuyPrice {
                newBuyPriceIsGreater = false
                changedCell = index
            }
            else {
                newBuyPriceIsGreater = nil
            }
            
            if oldSellPrice < currentSellPrice {
                newSellPriceIsGreater = true
                changedCell = index
            }
            else if oldSellPrice > currentSellPrice {
                newSellPriceIsGreater = false
                changedCell = index
            }
            else {
                newSellPriceIsGreater = nil
            }
            
            
            self.tableView.reloadData()
            self.reSort()
        }
    }
    
    // MARK: Table Sort functions
    
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
    
    
    
    func loadData() {
        self.markets.removeAll()
        self.copyMarkets.removeAll()
        self.tableView.reloadData()
        
//        self.currentBtcPrice = GlobalValues.currentBtcPrice
//        self.currentBtcPriceString = GlobalValues.currentBtcPriceString
        
//        self.btcPriceLabel.text = self.currentBtcPriceString

        self.populateTable()
        self.defaultSort()
        self.btcAmount.text = "1"
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
        self.btcPriceLabel.text = value.asCurrency
    }
    
    func populateTable() {
        if self.selectedCountry == "india" {
            
            // Zebpay
            let zebpayDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque non congue risus. Proin sagittis erat ut est accumsan, nec lobortis urna dignissim. Praesent ac mauris nisl. Maecenas in magna molestie, consequat erat quis, eleifend orci. Quisque ornare eu ligula eu porttitor. Mauris tempus enim sit amet risus molestie aliquet. Phasellus cursus ex venenatis tellus eleifend, ut pretium ipsum pulvinar. Suspendisse commodo scelerisque vestibulum. Vivamus maximus dignissim purus nec pharetra."
            let zebpayLinks = ["https://www.zebpay.com/", "https://twitter.com/zebpay", "https://www.facebook.com/zebpay/"]
            
            addExchangeToTable(title: "Zebpay", url: "https://www.zebpay.com/?utm_campaign=app_refferal_ref/ref/REF34005162&utm_medium=app&utm_source=zebpay_app_refferal", description: zebpayDescription, links: zebpayLinks)
            
            //Coinsecure
            let coinsecureDescription = ""
            let coinsecureLinks = ["", "", ""]
            addExchangeToTable(title: "Coinsecure", url: "https://coinsecure.in/signup/TVRWPVbGFVx7nYcr6YYM", description: coinsecureDescription, links: coinsecureLinks)
            
            // Koinex
            let koinexDescription = ""
            let koinexLinks = ["", "", ""]
            addExchangeToTable(title: "Koinex", url: "https://koinex.in/?ref=8271af", description: koinexDescription, links: koinexLinks)
            
            #if PRO_VERSION
                
                // Unocoin
                //            addExchangeToTable(title: "Unocoin", url: "https://www.unocoin.com/?referrerid=301527")
                
                // LocalBitcoins
                let localbitcoinsDescription = ""
                let localbitcoinsLinks = ["", "", ""]
                addExchangeToTable(title: "LocalBitcoins", url: "https://localbitcoins.com/?ch=cynk", description: localbitcoinsDescription, links: localbitcoinsLinks)
                
                // PocketBits
                let pocketbitsDescription = ""
                let pocketbitsLinks = ["", "", ""]
                addExchangeToTable(title: "PocketBits", url: "https://www.pocketbits.in/", description: pocketbitsDescription, links: pocketbitsLinks)
                
                // Throughbit
                let throughbitDescription = ""
                let throughbitLinks = ["", "", ""]
                addExchangeToTable(title: "Throughbit", url: "https://www.throughbit.com/", description: throughbitDescription, links: throughbitLinks)
            #endif
            
            #if LITE_VERSION
                liteMarkets = [("LocalBitcoins", "https://localbitcoins.com/?ch=cynk"), ("PocketBits", "https://www.pocketbits.in/"), ("Throughbit", "https://www.throughbit.com/")]
            #endif
            
            
        }
        else if self.selectedCountry == "usa" {
            
            // Coinbase
            let coinbaseDescription = ""
            let coinbaseLinks = ["", "", ""]
            addExchangeToTable(title: "Coinbase", url: "https://www.coinbase.com/join/57f5a4bef3a4f2006d0b7f4b", description: coinbaseDescription, links: coinbaseLinks)
            
            // Kraken
            let krakenDescription = ""
            let krakenLinks = ["", "", ""]
            addExchangeToTable(title: "Kraken", url: "https://www.kraken.com/", description: krakenDescription, links: krakenLinks)
            
            // LocalBitcoins
            let localbitcoinsDescription = ""
            let localbitcoinsLinks = ["", "", ""]
            addExchangeToTable(title: "LocalBitcoins", url: "https://localbitcoins.com/?ch=cynk", description: localbitcoinsDescription, links: localbitcoinsLinks)
            
            #if PRO_VERSION
                
                // Poloniex
                //            addExchangeToTable(title: "Poloniex", url: "https://poloniex.com/")
                
                // Gemini
                let geminiDescription = ""
                let geminiLinks = ["", "", ""]
                addExchangeToTable(title: "Gemini", url: "https://gemini.com/", description: geminiDescription, links: geminiLinks)
                
                
                // Bitfinex
                let bitfinexDescription = ""
                let bitfinexLinks = ["", "", ""]
                addExchangeToTable(title: "Bitfinex", url: "https://www.bitfinex.com/", description: bitfinexDescription, links: bitfinexLinks)
                
                
                // Bitstamp
                let bitstampDescription = ""
                let bitstampLinks = ["", "", ""]
                addExchangeToTable(title: "Bitstamp", url: "https://www.bitstamp.net/", description: bitstampDescription, links: bitstampLinks)
                
                
                // Bittrex
                //            addExchangeToTable(title: "Bittrex", url: "https://bittrex.com/")

            #endif
            
            #if LITE_VERSION
                liteMarkets = [("Poloniex", "https://poloniex.com/"), ("Gemini", "https://gemini.com/"), ("Bitfinex", "https://www.bitfinex.com/"), ("Bitstamp", "https://www.bitstamp.net/"), ("Bittrex", "https://bittrex.com/")]
            #endif
           
        }
        
    }
    
    func addExchangeToTable(title: String, url: String, description: String, links: [String]) {
        self.markets.append(Market(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
        self.copyMarkets.append((0, 0))
    }

    
    func flashBuyPriceLabel(cell: MarketTableViewCell, colour: UIColor) {
        UILabel.transition(with: cell.buyLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
            cell.buyLabel?.textColor = colour
        }, completion: { finished in
            UILabel.transition(with: cell.buyLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
                cell.buyLabel?.textColor = UIColor.black
            }, completion: nil)
        })
    }
    
    func flashSellPriceLabel(cell: MarketTableViewCell, colour: UIColor) {
        UILabel.transition(with: cell.sellLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
            cell.sellLabel?.textColor = colour
        }, completion: { finished in
            UILabel.transition(with: cell.sellLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
                cell.sellLabel?.textColor = UIColor.black
            }, completion: nil)
        })
    }
    
}

extension MarketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.markets.count + self.liteMarkets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        #if LITE_VERSION
            if indexPath.row >= self.markets.count {
                let liteCell = self.tableView.dequeueReusableCell(withIdentifier: "liteCell") as? MarketTableViewCell!
                let index = indexPath.row - self.markets.count
                liteCell!.siteLabel?.setTitle(liteMarkets[index].0, for: .normal)
                liteCell!.siteLabel.url = URL(string: liteMarkets[index].1)
                liteCell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
                return liteCell!
            }
        #endif
        
        let market = self.markets[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? MarketTableViewCell!
        cell!.siteLabel?.setTitle(market.title, for: .normal)
        cell!.siteLabel.url = market.siteLink
        cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        cell!.siteLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        cell!.buyLabel?.text = market.buyPrice.asCurrency
        cell!.buyLabel.adjustsFontSizeToFitWidth = true
        
        cell!.sellLabel?.text = market.sellPrice.asCurrency
        cell!.sellLabel.adjustsFontSizeToFitWidth = true
        
        if indexPath.row == changedCell {
            print("here")
            if newBuyPriceIsGreater != nil {
                if newBuyPriceIsGreater! {
                    flashBuyPriceLabel(cell: cell!, colour: greenColour)
                }
                else if !newBuyPriceIsGreater! {
                    flashBuyPriceLabel(cell: cell!, colour: redColour)
                }
            }
            
            if newSellPriceIsGreater != nil {
                if newSellPriceIsGreater! {
                    flashSellPriceLabel(cell: cell!, colour: greenColour)
                }
                else if !newSellPriceIsGreater! {
                    flashSellPriceLabel(cell: cell!, colour: redColour)
                }
            }
            
            changedCell = -1
        }
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationViewController = segue.destination
        if let marketDetailController = destinationViewController as? MarketDetailViewController {
            if let index = tableView.indexPathForSelectedRow?.row {
                if let title = self.markets[index].title {
                    marketDetailController.market = title
                    marketDetailController.databaseChildTitle = self.databaseTitles[title]
                    marketDetailController.marketDescription = self.markets[index].description
                    marketDetailController.links = self.markets[index].links
                }
            }
        }
        
    }

}

