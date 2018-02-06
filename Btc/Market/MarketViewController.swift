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
    
    var currentCoin: String! = "BTC"
    
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
    
    var coinMarkets: [String: String] = [:]
    
    var databaseReference: DatabaseReference!
    
    var exchangeRefs: [(DatabaseReference, String, String)] = []
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        self.loadData()
        
        // for current bitcoin price
        let tableTitle = currentCoin!
        currentBtcRef = Database.database().reference().child(tableTitle)
        
        currentBtcRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let currencyData = dict[GlobalValues.currency!] as? [String: Any] {
                    let oldBtcPrice = self.currentBtcPrice
                    self.currentBtcPrice = currencyData["price"] as! Double
                    
                    let unixTime = currencyData["timestamp"] as! Double
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
                        
                    }
                    if let currencyMarkets = currencyData["markets"] as? [String: String] {
                        self.coinMarkets = currencyMarkets
                        self.setupCoinMarketRefs()
                    }
                }
            }
                
        })
        
        textFieldValue = 1.0
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentBtcRef.removeAllObservers()
        
        for exchangeRef in exchangeRefs {
            exchangeRef.0.removeAllObservers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Firebase helper functions
    
    func setupCoinMarketRefs() {
        for (key, value) in self.coinMarkets {
            exchangeRefs.append((databaseReference.child(value), key, value))
        }
        
        for exchangeRef in exchangeRefs {
            exchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: exchangeRef.1)
                }
            })
        }
        
        self.populateTable()
        self.defaultSort()
        self.btcAmount.text = "1"
    }
    
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
        
        for coinMarket in coinMarkets {
            print(coinMarket.key)
            if let currentMarketInfo = marketInformation[coinMarket.key] {
                addExchangeToTable(title: coinMarket.key, url: currentMarketInfo["url"]!, description: "", links: [])
            }
            
        }
//        if self.selectedCountry == "india" {
//
//            for coinMarket in coinMarkets {
//                print(coinMarket.key)
//                if let currentMarketInfo = marketInformation[coinMarket.key] {
//                    addExchangeToTable(title: coinMarket.key, url: currentMarketInfo["url"]!, description: "", links: [])
//                }
//
//            }
//
//
//        }
//        else if self.selectedCountry == "usa" {
//
//
//        }
        
//        else if self.selectedCountry == "eu" {
//            // Coinbase
//            let coinbaseDescription = ""
//            let coinbaseLinks = ["", "", ""]
//            addExchangeToTable(title: "Coinbase", url: "https://www.coinbase.com/join/57f5a4bef3a4f2006d0b7f4b", description: coinbaseDescription, links: coinbaseLinks)
//
//            // Kraken
//            let krakenDescription = ""
//            let krakenLinks = ["", "", ""]
//            addExchangeToTable(title: "Kraken", url: "https://www.kraken.com/", description: krakenDescription, links: krakenLinks)
//
//            // LocalBitcoins
//            let localbitcoinsDescription = ""
//            let localbitcoinsLinks = ["", "", ""]
//            addExchangeToTable(title: "LocalBitcoins", url: "https://localbitcoins.com/?ch=cynk", description: localbitcoinsDescription, links: localbitcoinsLinks)
//        }
        
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
                    marketDetailController.databaseChildTitle = self.coinMarkets[title]
                    marketDetailController.marketDescription = self.markets[index].description
                    marketDetailController.links = self.markets[index].links
                }
            }
        }
        
    }

}

