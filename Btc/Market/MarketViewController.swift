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
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var btcMarketsTable: UITableView!
    @IBOutlet weak var btcTableHeightConstraint: NSLayoutConstraint!
    
    #if LITE_VERSION
    @IBAction func upgradeButton(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/id1266256984")!)
    }
    #endif
    
    let defaults = UserDefaults.standard

    var selectedCountry: String!
    
    var currentCoin: String! = "BTC"
    
    var currentCoinPriceString = "0"
    var currentCoinPrice: Double = 0.0

    var textFieldValue = 1.0

    var buySortButtonCounter = 0
    var sellSortButtonCounter = 0
    
    let buyTitleArray = ["Buy", "Buy ▲", "Buy ▼"]
    let sellTitleArray = ["Sell", "Sell ▲", "Sell ▼"]
    
    var markets: [Market] = []
    var cryptoMarkets: [Market] = []

    var liteMarkets : [(String, String)] = []
    var copyMarkets: [(Double, Double)] = []
    var copyCryptoMarkets: [(Double, Double)] = []

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: Firebase database references
    
    var coinRef: DatabaseReference!
    
    var coinMarkets: [String: String] = [:]
    var coinBtcMarkets: [String: String] = [:]
    
    var databaseReference: DatabaseReference!
    
    var fiatExchangeRefs: [(DatabaseReference, String, String)] = []
    var cryptoExchangeRefs: [(DatabaseReference, String, String)] = []
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var changedCell = -1
    var newBuyPriceIsGreater: Bool? = true
    var newSellPriceIsGreater: Bool? = true
    
    var selectedMarket: String!
    
    @IBAction func refreshButton(_ sender: Any) {
        self.btcPriceLabel.text = currentCoinPriceString
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
        
        self.btcMarketsTable.delegate = self
        self.btcMarketsTable.dataSource = self
        self.btcMarketsTable.tableFooterView = UIView()
        
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
        
        // for current coin price
        let tableTitle = currentCoin!
        coinRef = Database.database().reference().child(tableTitle)
        
        coinRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let currencyData = dict[GlobalValues.currency!] as? [String: Any] {
                    let oldBtcPrice = self.currentCoinPrice
                    self.currentCoinPrice = currencyData["price"] as! Double
                    
                    let unixTime = currencyData["timestamp"] as! Double
                    var colour: UIColor
                    
                    if self.currentCoinPrice > oldBtcPrice {
                        colour = self.greenColour
                    }
                    else if self.currentCoinPrice < oldBtcPrice {
                        colour = self.redColour
                    }
                    else {
                        colour = UIColor.black
                    }
                    
                    GlobalValues.currentBtcPriceString = self.currentCoinPrice.asCurrency
                    GlobalValues.currentBtcPrice = self.currentCoinPrice
                    DispatchQueue.main.async {
                        self.btcPriceLabel.text = (self.currentCoinPrice * self.textFieldValue).asCurrency
                        
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
//                        self.setupCoinMarketRefs()
                    }
                }
                
                if let btcData = dict["BTC"] as? [String: Any] {
                    if let btcMarkets = btcData["markets"] as? [String: String] {
                        self.coinBtcMarkets = btcMarkets
                    }
                }
                
                self.setupCoinMarketRefs()
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
        btcTableHeightConstraint.constant = self.btcMarketsTable.contentSize.height
        
    }
    
    override func viewWillLayoutSubviews() {
//        var frame = tableView.frame
//        frame.size.height = tableView.contentSize.height
//        tableView.frame = frame
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coinRef.removeAllObservers()
        
        for fiatExchangeRef in fiatExchangeRefs {
            fiatExchangeRef.0.removeAllObservers()
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Firebase helper functions
    
    func setupCoinMarketRefs() {
        for (key, value) in self.coinMarkets {
            fiatExchangeRefs.append((databaseReference.child(value), key, value))
        }
        
        for (key, value) in self.coinBtcMarkets {
            cryptoExchangeRefs.append((databaseReference.child(value), key, value))
        }
        
        for fiatExchangeRef in fiatExchangeRefs {
            fiatExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.updateFirebaseObservedData(dict: dict, title: fiatExchangeRef.1)
                }
            })
        }
        
        for cryptoExchangeRef in cryptoExchangeRefs {
            if cryptoExchangeRef.1 == "Kucoin" { // Kucoin historial data available through their API
                cryptoExchangeRef.0.observe(.value, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedDataCrypto(dict: dict, title: cryptoExchangeRef.1)
                    }
                })
            }
            else {
                cryptoExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.updateFirebaseObservedDataCrypto(dict: dict, title: cryptoExchangeRef.1)
                    }
                })
            }
        }
        
        self.populateFiatTable()
        self.populateCryptoTable()
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
    
    func updateFirebaseObservedDataCrypto(dict: [String: AnyObject], title: String) {
        
        let lastPrice = dict["last_price"] as! Double
        
        if let index = self.cryptoMarkets.index(where: {$0.title == title}) {
            
//            let oldBuyPrice = self.copyMarkets[index].0
//            let oldSellPrice = self.copyMarkets[index].1
//
            self.cryptoMarkets[index].lastPrice = lastPrice * self.textFieldValue
//            self.cryptoMarkets[index].sellPrice = currentSellPrice * self.textFieldValue
//
//            // update other array
//            self.copyMarkets[index].0 = currentBuyPrice
//            self.copyMarkets[index].1 = currentSellPrice
//
//            if oldBuyPrice < currentBuyPrice {
//                newBuyPriceIsGreater = true
//                changedCell = index
//            }
//            else if oldBuyPrice > currentBuyPrice {
//                newBuyPriceIsGreater = false
//                changedCell = index
//            }
//            else {
//                newBuyPriceIsGreater = nil
//            }
//
//            if oldSellPrice < currentSellPrice {
//                newSellPriceIsGreater = true
//                changedCell = index
//            }
//            else if oldSellPrice > currentSellPrice {
//                newSellPriceIsGreater = false
//                changedCell = index
//            }
//            else {
//                newSellPriceIsGreater = nil
//            }
            
            
            self.btcMarketsTable.reloadData()
//            self.reSort()
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
        
        tableHeightConstraint.constant = tableView.contentSize.height
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
        self.coinMarkets.removeAll()
        self.cryptoMarkets.removeAll()
        self.tableView.reloadData()
        
//        self.currentCoinPrice = GlobalValues.currentCoinPrice
//        self.currentCoinPriceString = GlobalValues.currentCoinPriceString
        
//        self.btcPriceLabel.text = self.currentCoinPriceString

//        self.populateFiatTable()
//        self.populateCryptoTable()
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
                let updatedValue = self.currentCoinPrice*value
                self.updatecurrentCoinPrice(updatedValue)
                
                for index in 0..<self.copyMarkets.count {
                    self.markets[index].buyPrice = self.copyMarkets[index].0 * value
                    self.markets[index].sellPrice = self.copyMarkets[index].1 * value
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func updatecurrentCoinPrice(_ value: Double) {
        self.btcPriceLabel.text = value.asCurrency
    }
    
    func populateFiatTable() {
        
        for coinMarket in coinMarkets {
            if let currentMarketInfo = marketInformation[coinMarket.key] {
                addExchangeToTable(title: coinMarket.key, url: currentMarketInfo["url"]!, description: "", links: [])
            }
            
        }
    }
    
    func populateCryptoTable() {
        for coinBtcMarket in coinBtcMarkets {
            if let currentMarketInfo = marketInformation[coinBtcMarket.key] {
                addCryptoExchangeToTable(title: coinBtcMarket.key, url: currentMarketInfo["url"]!, description: "", links: [])
            }
        }
    }
    
    func addExchangeToTable(title: String, url: String, description: String, links: [String]) {
        self.markets.append(Market(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
        self.copyMarkets.append((0, 0))
    }
    
    func addCryptoExchangeToTable(title: String, url: String, description: String, links: [String]) {
        self.cryptoMarkets.append(Market(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
        self.copyCryptoMarkets.append((0, 0))
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
        var count: Int?
        
        if self.tableView == tableView {
            count = self.markets.count + self.liteMarkets.count
        }
        
        if self.btcMarketsTable == tableView {
            count = self.cryptoMarkets.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if self.tableView == tableView {
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
        
        if self.btcMarketsTable == tableView {
            print(self.cryptoMarkets.count)
            let cell = self.btcMarketsTable.dequeueReusableCell(withIdentifier: "cryptoMarketCell") as? CryptoMarketTableViewCell!
            let market = self.cryptoMarkets[indexPath.row]

            cell!.exchangeName.text = market.title
            cell!.lastPrice.text = "\(market.lastPrice!)"
            cell!.percentageChangeLabel.text = market.title
            
            return cell!
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

