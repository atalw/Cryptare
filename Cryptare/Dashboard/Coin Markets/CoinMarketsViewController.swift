//
//  FirstViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import Armchair
import SwiftyUserDefaults

class CoinMarketsViewController: UIViewController {
  
  var selectedCountry: String!
  
  var currentCoin: String! = "BTC"
  
  var currentCoinPriceString = "0"
  var currentCoinPrice: Double = 0.0
  
  var textFieldValue = 1.0
  
  var buySortButtonCounter = 0
  var sellSortButtonCounter = 0
  
  var lastPriceSortButtonCounter = 0
  var percentChangeSortButtonCounter = 0
  
  let buyTitleArray = ["Buy", "Buy ▲", "Buy ▼"]
  let sellTitleArray = ["Sell", "Sell ▲", "Sell ▼"]
  
  let lastPriceTitleArray = ["Last Price", "Last Price ▲", "Last Price ▼"]
  let percentChangeTitleArray = ["24hr Change", "24hr Change ▲", "24hr Change ▼"]
  
  var markets: [CoinMarket] = []
  var usdtMarkets: [CoinMarket] = []
  var btcMarkets: [CoinMarket] = []
  var ethMarkets: [CoinMarket] = []
  
  var liteMarkets : [(String, String)] = []
  
  var copyMarkets: [(Double, Double)] = []
  var copyUsdtMarkets: [(Double, Double)] = []
  var copyBtcMarkets: [(Double, Double)] = []
  var copyEthMarkets: [(Double, Double)] = []
  
  
  var coinRef: DatabaseReference!
  
  var coinMarkets: [String: String] = [:]
  var coinUsdtMarkets: [String: String] = [:]
  var coinBtcMarkets: [String: String] = [:]
  var coinEthMarkets: [String: String] = [:]
  
  var databaseReference: DatabaseReference!
  
  var all_exchanges_update_type: [String: String] = [:]
  
  var fiatExchangeRefs: [(DatabaseReference, String, String)] = []
  var usdtExchangeRefs: [(DatabaseReference, String, String)] = []
  var btcExchangeRefs: [(DatabaseReference, String, String)] = []
  var ethExchangeRefs: [(DatabaseReference, String, String)] = []
  
  let greenColour = UIColor.init(hex: "#2ecc71")
  let redColour = UIColor.init(hex: "#e74c3c")
  
  var changedCell = -1
  var changedTableView: UITableView!
  var newBuyPriceIsGreater: Bool? = true
  var newSellPriceIsGreater: Bool? = true
  
  var selectedMarket: String!
  
  var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: .zero)
  
  
  // MARK: IBOutlets
  
  @IBOutlet var btcPriceLabel: UILabel! {
    didSet {
      btcPriceLabel.adjustsFontSizeToFitWidth = true
      btcPriceLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet var btcAmount: UITextField!
  
  @IBOutlet weak var coinNameLabel: UILabel! {
    didSet {
      coinNameLabel.adjustsFontSizeToFitWidth = true
      coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet var infoButton: UIBarButtonItem!
  
  @IBOutlet weak var buySortButton: UIButton!
  @IBOutlet weak var sellSortButton: UIButton!
  
  @IBOutlet weak var buySortUsdtButton: UIButton!
  @IBOutlet weak var sellSortUsdtButton: UIButton!
  
  @IBOutlet weak var buySortBtcButton: UIButton!
  @IBOutlet weak var sellSortBtcButton: UIButton!
  
  @IBOutlet weak var buySortEthButton: UIButton!
  @IBOutlet weak var sellSortEthButton: UIButton!
  
  @IBOutlet weak var fiatMarketDescriptionLabel: UILabel! {
    didSet {
      fiatMarketDescriptionLabel.text = "Markets that support \(currentCoin!) purchase directly using \(GlobalValues.currency!)."
      fiatMarketDescriptionLabel.adjustsFontSizeToFitWidth = true
      fiatMarketDescriptionLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var usdtMarketDescriptionLabel: UILabel! {
    didSet {
      usdtMarketDescriptionLabel.text = "Markets that support \(currentCoin!) purchase directly using USDT."
      usdtMarketDescriptionLabel.adjustsFontSizeToFitWidth = true
      usdtMarketDescriptionLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var btcMarketDescriptionLabel: UILabel! {
    didSet {
      btcMarketDescriptionLabel.text = "Markets that support \(currentCoin!) purchase directly using BTC (₿)."
      btcMarketDescriptionLabel.adjustsFontSizeToFitWidth = true
      btcMarketDescriptionLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var ethMarketDescriptionLabel: UILabel! {
    didSet {
      ethMarketDescriptionLabel.text = "Markets that support \(currentCoin!) purchase directly using ETH."
      ethMarketDescriptionLabel.adjustsFontSizeToFitWidth = true
      ethMarketDescriptionLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  @IBOutlet weak var fiatMarketsTitleLabel: UILabel! {
    didSet {
      fiatMarketsTitleLabel.adjustsFontSizeToFitWidth = true
      fiatMarketsTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var usdtMarketsTitleLabel: UILabel! {
    didSet {
      usdtMarketsTitleLabel.adjustsFontSizeToFitWidth = true
      usdtMarketsTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var btcMarketsTitleLabel: UILabel! {
    didSet {
      btcMarketsTitleLabel.adjustsFontSizeToFitWidth = true
      btcMarketsTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var ethMarketsTitleLabel: UILabel! {
    didSet {
      ethMarketsTitleLabel.adjustsFontSizeToFitWidth = true
      ethMarketsTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.tableFooterView = UIView(frame: .zero)
      
      tableView.theme_backgroundColor = GlobalPicker.mainBackgroundColor
      tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    }
  }
  
  @IBOutlet weak var usdtMarketsTable: UITableView! {
    didSet {
      usdtMarketsTable.delegate = self
      usdtMarketsTable.dataSource = self
      usdtMarketsTable.tableFooterView = UIView(frame: .zero)
      
      usdtMarketsTable.theme_backgroundColor = GlobalPicker.mainBackgroundColor
      usdtMarketsTable.theme_separatorColor = GlobalPicker.tableSeparatorColor
    }
  }
  @IBOutlet weak var btcMarketsTable: UITableView! {
    didSet {
      btcMarketsTable.delegate = self
      btcMarketsTable.dataSource = self
      btcMarketsTable.tableFooterView = UIView(frame: .zero)
      
      btcMarketsTable.theme_backgroundColor = GlobalPicker.mainBackgroundColor
      btcMarketsTable.theme_separatorColor = GlobalPicker.tableSeparatorColor
    }
  }
  
  
  @IBOutlet weak var ethMarketsTable: UITableView! {
    didSet {
      ethMarketsTable.delegate = self
      ethMarketsTable.dataSource = self
      ethMarketsTable.tableFooterView = UIView(frame: .zero)
      
      ethMarketsTable.theme_backgroundColor = GlobalPicker.mainBackgroundColor
      ethMarketsTable.theme_separatorColor = GlobalPicker.tableSeparatorColor
    }
  }
  
  @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var usdtTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var btcTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var ethTableHeightConstraint: NSLayoutConstraint!
  
  
  @IBOutlet weak var fiatTableHeader: UIView! {
    didSet {
      fiatTableHeader.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    }
  }
  @IBOutlet weak var usdtTableHeader: UIView! {
    didSet {
      usdtTableHeader.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    }
  }
  @IBOutlet weak var btcTableHeader: UIView! {
    didSet {
      btcTableHeader.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    }
  }
  @IBOutlet weak var ethTableHeader: UIView! {
    didSet {
      ethTableHeader.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    }
  }
  
  @IBOutlet weak var marketsLockView: UIView! {
    didSet {
//      marketsLockView.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    }
  }
  @IBOutlet weak var unlockMarketsPriceButton: UIButton! {
    didSet {
      //            unlockMarketsPriceButton.theme
    }
  }
  @IBAction func learnSubscriptionButtonTapped(_ sender: Any) {
    let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
    let subscriptionsViewController = settingsStoryboard.instantiateViewController(withIdentifier: "SubscriptionsViewController")
    self.present(subscriptionsViewController, animated: true, completion: nil)
  }
  
  // MARK: VC Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Armchair.userDidSignificantEvent(true)
    
    self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    
    coinNameLabel.text = currentCoin
    
    self.btcAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    self.buySortButton.addTarget(self, action: #selector(buySortButtonTapped), for: .touchUpInside)
    
    sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    self.sellSortButton.addTarget(self, action: #selector(sellSortButtonTapped), for: .touchUpInside)
    
    buySortUsdtButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    self.buySortUsdtButton.addTarget(self, action: #selector(buySortButtonTapped), for: .touchUpInside)
    
    sellSortUsdtButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    self.sellSortUsdtButton.addTarget(self, action: #selector(sellSortButtonTapped), for: .touchUpInside)
    
    buySortBtcButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    self.buySortBtcButton.addTarget(self, action: #selector(buySortButtonTapped), for: .touchUpInside)
    
    sellSortBtcButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    self.sellSortBtcButton.addTarget(self, action: #selector(sellSortButtonTapped), for: .touchUpInside)
    
    buySortEthButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    self.buySortEthButton.addTarget(self, action: #selector(buySortButtonTapped), for: .touchUpInside)
    
    sellSortEthButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    self.sellSortEthButton.addTarget(self, action: #selector(sellSortButtonTapped), for: .touchUpInside)
    
    
    activityIndicator.center = self.tableView.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    self.tableView.addSubview(activityIndicator)
    
    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    
    databaseReference = Database.database().reference()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.selectedCountry = Defaults[.selectedCountry]
    
    self.databaseReference.child("all_exchanges_update_type").observe(.value, with: {(snapshot) -> Void in
      if let dict = snapshot.value as? [String: String] {
        self.all_exchanges_update_type = dict
        self.loadData()
      }
    })
    
    textFieldValue = 1.0
    
    let freeCoins = ["BTC", "ETH", "XRP", "BCH", "LTC"]
    
    #if DEBUG
    marketsLockView.isHidden = true
    #else
    if freeCoins.contains(currentCoin) {
      marketsLockView.isHidden = true
    }
    else {
      let unlockMarketsPurchased = Defaults[.subscriptionPurchased]
      if unlockMarketsPurchased == true {
        marketsLockView.isHidden = true
      }
      else {
        marketsLockView.isHidden = false
      }
    }
    #endif
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseService.shared.updateScreenName(screenName: "Markets", screenClass: "MarketsViewController")
    
    FirebaseService.shared.coin_markets_view_appeared(coin: currentCoin, currency: GlobalValues.currency!)
    
//    if currentReachabilityStatus == .notReachable {
//      let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
//      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
//      present(alert, animated: true, completion: nil)
//    }
    
  }
  
  override func viewWillLayoutSubviews() {
    
    if coinMarkets.count != 0 {
      tableView.backgroundView = nil
//      tableHeightConstraint.constant = tableView.contentSize.height
    }
    else {
      let messageLabel = UILabel(frame: .zero)
      messageLabel.text = "No markets currently available."
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      tableHeightConstraint.constant = CGFloat(140)
      tableView.backgroundView = messageLabel
    }
    
    if coinUsdtMarkets.count != 0 {
      usdtMarketsTable.backgroundView = nil
      //      btcTableHeightConstraint.constant = self.btcMarketsTable.contentSize.height
    }
    else {
      let messageLabel = UILabel(frame: .zero)
      messageLabel.text = "No markets currently available."
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      usdtTableHeightConstraint.constant = CGFloat(140)
      usdtMarketsTable.backgroundView = messageLabel
    }
    
    if coinBtcMarkets.count != 0 {
      btcMarketsTable.backgroundView = nil
//      btcTableHeightConstraint.constant = self.btcMarketsTable.contentSize.height
    }
    else {
      let messageLabel = UILabel(frame: .zero)
      messageLabel.text = "No markets currently available."
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      btcTableHeightConstraint.constant = CGFloat(140)
      btcMarketsTable.backgroundView = messageLabel
    }
    
    if coinEthMarkets.count != 0 {
      ethMarketsTable.backgroundView = nil
//      ethTableHeightConstraint.constant = self.ethMarketsTable.contentSize.height
    }
    else {
      let messageLabel = UILabel(frame: .zero)
      messageLabel.text = "No markets currently available."
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      ethTableHeightConstraint.constant = CGFloat(140)
      ethMarketsTable.backgroundView = messageLabel
    }
    
    tableView.reloadData()
    btcMarketsTable.reloadData()
    ethMarketsTable.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if coinRef != nil {
      coinRef.removeAllObservers()
    }
    
    for fiatExchangeRef in fiatExchangeRefs {
      fiatExchangeRef.0.removeAllObservers()
    }
    
    for usdtExchangeRef in usdtExchangeRefs {
      usdtExchangeRef.0.removeAllObservers()
    }
    
    for btcExchangeRef in btcExchangeRefs {
      btcExchangeRef.0.removeAllObservers()
    }
    
    for ethExchangeRef in ethExchangeRefs {
      ethExchangeRef.0.removeAllObservers()
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
    
    for fiatExchangeRef in fiatExchangeRefs {
      let exchangeName = fiatExchangeRef.1
      if all_exchanges_update_type[exchangeName] == "update" {
        fiatExchangeRef.0.observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedData(dict: dict, title: fiatExchangeRef.1)
          }
        })
      }
      else {
        fiatExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedData(dict: dict, title: fiatExchangeRef.1)
          }
        })
      }
      
    }
    
    self.populateFiatTable()
    self.defaultSort()
    self.btcAmount.text = "1"
  }
  
  func setupCoinUsdtMarketRefs() {
    
    for (key, value) in self.coinUsdtMarkets {
      usdtExchangeRefs.append((databaseReference.child(value), key, value))
    }
    
    for usdtExchangeRef in usdtExchangeRefs {
      let exchangeName = usdtExchangeRef.1
      if all_exchanges_update_type[exchangeName] == "update" {
        usdtExchangeRef.0.observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataUsdt(dict: dict, title: usdtExchangeRef.1)
          }
        })
      }
      else {
        usdtExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataUsdt(dict: dict, title: usdtExchangeRef.1)
          }
        })
      }
    }
    
    self.populateUsdtTable()
    
  }
  
  func setupCoinBtcMarketRefs() {
    
    for (key, value) in self.coinBtcMarkets {
      btcExchangeRefs.append((databaseReference.child(value), key, value))
    }
    
    for btcExchangeRef in btcExchangeRefs {
      let exchangeName = btcExchangeRef.1
      if all_exchanges_update_type[exchangeName] == "update" {
        btcExchangeRef.0.observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataBtc(dict: dict, title: btcExchangeRef.1)
          }
        })
      }
      else {
        btcExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataBtc(dict: dict, title: btcExchangeRef.1)
          }
        })
      }
    }
    
    self.populateBtcTable()
    
  }
  
  func setupCoinEthMarketRefs() {
    
    for (key, value) in self.coinEthMarkets {
      ethExchangeRefs.append((databaseReference.child(value), key, value))
    }
    
    for ethExchangeRef in ethExchangeRefs {
      let exchangeName = ethExchangeRef.1
      if all_exchanges_update_type[exchangeName] == "update" {
        ethExchangeRef.0.observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataEth(dict: dict, title: ethExchangeRef.1)
          }
        })
      }
      else {
        ethExchangeRef.0.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String: AnyObject] {
            self.updateFirebaseObservedDataEth(dict: dict, title: ethExchangeRef.1)
          }
        })
      }
    }
    
    self.populateEthTable()
    
  }
  
  func updateFirebaseObservedData(dict: [String: AnyObject], title: String) {
    
    var currentBuyPrice = dict["buy_price"] as! Double
    var currentSellPrice = dict["sell_price"] as! Double
    
    if currentBuyPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentBuyPrice = lastPrice
        }
      }
    }
    
    if currentSellPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentSellPrice = lastPrice
        }
      }
    }
    
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
        changedTableView = tableView
      }
      else if oldBuyPrice > currentBuyPrice {
        newBuyPriceIsGreater = false
        changedCell = index
        changedTableView = tableView
      }
      else {
        newBuyPriceIsGreater = nil
      }
      
      if oldSellPrice < currentSellPrice {
        newSellPriceIsGreater = true
        changedCell = index
        changedTableView = tableView
      }
      else if oldSellPrice > currentSellPrice {
        newSellPriceIsGreater = false
        changedCell = index
        changedTableView = tableView
      }
      else {
        newSellPriceIsGreater = nil
      }
      
      
      self.tableView.reloadData()
      self.reSort()
    }
  }
  
  func updateFirebaseObservedDataUsdt(dict: [String: AnyObject], title: String) {
    
    let unformattedBuyPrice = dict["buy_price"] as! Double
    let unformattedSellPrice = dict["sell_price"] as! Double
    
    var currentBuyPrice = round(unformattedBuyPrice*1000)/1000
    var currentSellPrice = round(unformattedSellPrice*1000)/1000
    
    if currentBuyPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentBuyPrice = lastPrice
        }
      }
    }
    
    if currentSellPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentSellPrice = lastPrice
        }
      }
    }
    
    if let index = self.usdtMarkets.index(where: {$0.title == title}) {
      
      let oldBuyPrice = self.copyUsdtMarkets[index].0
      let oldSellPrice = self.copyUsdtMarkets[index].1
      
      self.usdtMarkets[index].buyPrice = currentBuyPrice * self.textFieldValue
      self.usdtMarkets[index].sellPrice = currentSellPrice * self.textFieldValue
      
      // update other array
      self.copyUsdtMarkets[index].0 = currentBuyPrice
      self.copyUsdtMarkets[index].1 = currentSellPrice
      
      if oldBuyPrice < currentBuyPrice {
        newBuyPriceIsGreater = true
        changedCell = index
        changedTableView = usdtMarketsTable
      }
      else if oldBuyPrice > currentBuyPrice {
        newBuyPriceIsGreater = false
        changedCell = index
        changedTableView = usdtMarketsTable
      }
      else {
        newBuyPriceIsGreater = nil
      }
      
      if oldSellPrice < currentSellPrice {
        newSellPriceIsGreater = true
        changedCell = index
        changedTableView = usdtMarketsTable
      }
      else if oldSellPrice > currentSellPrice {
        newSellPriceIsGreater = false
        changedCell = index
        changedTableView = usdtMarketsTable
      }
      else {
        newSellPriceIsGreater = nil
      }
      
      self.usdtMarketsTable.reloadData()
      self.reSort()
    }
  }
  
  func updateFirebaseObservedDataBtc(dict: [String: AnyObject], title: String) {
    
    let unformattedBuyPrice = dict["buy_price"] as! Double
    let unformattedSellPrice = dict["sell_price"] as! Double
    
    var currentBuyPrice = round(unformattedBuyPrice*100000000)/100000000
    var currentSellPrice = round(unformattedSellPrice*100000000)/100000000
    
    if currentBuyPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentBuyPrice = lastPrice
        }
      }
    }
    
    if currentSellPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentSellPrice = lastPrice
        }
      }
    }
    
    if let index = self.btcMarkets.index(where: {$0.title == title}) {
      
      let oldBuyPrice = self.copyBtcMarkets[index].0
      let oldSellPrice = self.copyBtcMarkets[index].1
      
      self.btcMarkets[index].buyPrice = currentBuyPrice * self.textFieldValue
      self.btcMarkets[index].sellPrice = currentSellPrice * self.textFieldValue
      
      // update other array
      self.copyBtcMarkets[index].0 = currentBuyPrice
      self.copyBtcMarkets[index].1 = currentSellPrice
      
      if oldBuyPrice < currentBuyPrice {
        newBuyPriceIsGreater = true
        changedCell = index
        changedTableView = btcMarketsTable
      }
      else if oldBuyPrice > currentBuyPrice {
        newBuyPriceIsGreater = false
        changedCell = index
        changedTableView = btcMarketsTable
      }
      else {
        newBuyPriceIsGreater = nil
      }
      
      if oldSellPrice < currentSellPrice {
        newSellPriceIsGreater = true
        changedCell = index
        changedTableView = btcMarketsTable
      }
      else if oldSellPrice > currentSellPrice {
        newSellPriceIsGreater = false
        changedCell = index
        changedTableView = btcMarketsTable
      }
      else {
        newSellPriceIsGreater = nil
      }
      
      self.btcMarketsTable.reloadData()
      self.reSort()
    }
  }
  
  func updateFirebaseObservedDataEth(dict: [String: AnyObject], title: String) {
    
    let unformattedBuyPrice = dict["buy_price"] as! Double
    let unformattedSellPrice = dict["sell_price"] as! Double
    
    var currentBuyPrice = round(unformattedBuyPrice*100000000)/100000000
    var currentSellPrice = round(unformattedSellPrice*100000000)/100000000
    
    if currentBuyPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentBuyPrice = lastPrice
        }
      }
    }
    
    if currentSellPrice == 0 {
      if let lastPrice = dict["last_price"] as? Double {
        if lastPrice > 0 {
          currentSellPrice = lastPrice
        }
      }
    }
    
    if let index = self.ethMarkets.index(where: {$0.title == title}) {
      
      let oldBuyPrice = self.copyEthMarkets[index].0
      let oldSellPrice = self.copyEthMarkets[index].1
      
      self.ethMarkets[index].buyPrice = currentBuyPrice * self.textFieldValue
      self.ethMarkets[index].sellPrice = currentSellPrice * self.textFieldValue
      
      // update other array
      self.copyEthMarkets[index].0 = currentBuyPrice
      self.copyEthMarkets[index].1 = currentSellPrice
      
      if oldBuyPrice < currentBuyPrice {
        newBuyPriceIsGreater = true
        changedCell = index
        changedTableView = ethMarketsTable
      }
      else if oldBuyPrice > currentBuyPrice {
        newBuyPriceIsGreater = false
        changedCell = index
        changedTableView = ethMarketsTable
      }
      else {
        newBuyPriceIsGreater = nil
      }
      
      if oldSellPrice < currentSellPrice {
        newSellPriceIsGreater = true
        changedCell = index
        changedTableView = ethMarketsTable
      }
      else if oldSellPrice > currentSellPrice {
        newSellPriceIsGreater = false
        changedCell = index
        changedTableView = ethMarketsTable
      }
      else {
        newSellPriceIsGreater = nil
      }
      
      self.ethMarketsTable.reloadData()
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
      self.usdtMarkets.sort(by: {$0.buyPrice < $1.buyPrice})
      self.btcMarkets.sort(by: {$0.buyPrice < $1.buyPrice})
      self.ethMarkets.sort(by: {$0.buyPrice < $1.buyPrice})
      
      self.copyMarkets.sort(by: {$0.0 < $1.0})
      self.copyUsdtMarkets.sort(by: {$0.0 < $1.0})
      self.copyBtcMarkets.sort(by: {$0.0 < $1.0})
      self.copyEthMarkets.sort(by: {$0.0 < $1.0})
    }
    else if buySortButtonCounter == 2 {
      self.markets.sort(by: {$0.buyPrice > $1.buyPrice})
      self.usdtMarkets.sort(by: {$0.buyPrice > $1.buyPrice})
      self.btcMarkets.sort(by: {$0.buyPrice > $1.buyPrice})
      self.ethMarkets.sort(by: {$0.buyPrice > $1.buyPrice})
      
      self.copyMarkets.sort(by: {$0.0 > $1.0})
      self.copyUsdtMarkets.sort(by: {$0.0 > $1.0})
      self.copyBtcMarkets.sort(by: {$0.0 > $1.0})
      self.copyEthMarkets.sort(by: {$0.0 > $1.0})
    }
    buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortUsdtButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortBtcButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortEthButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    
    sellSortButtonCounter = 0
    sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortUsdtButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortBtcButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortEthButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    
    tableView.reloadData()
    usdtMarketsTable.reloadData()
    btcMarketsTable.reloadData()
    ethMarketsTable.reloadData()
  }
  
  @objc func sellSortButtonTapped() {
    sellSortButtonCounter = (sellSortButtonCounter + 1) % sellTitleArray.count
    if sellSortButtonCounter == 0 {
      sellSortButtonCounter = 1
    }
    if sellSortButtonCounter == 1 {
      self.markets.sort(by: {$0.sellPrice < $1.sellPrice})
      self.usdtMarkets.sort(by: {$0.sellPrice < $1.sellPrice})
      self.btcMarkets.sort(by: {$0.sellPrice < $1.sellPrice})
      self.ethMarkets.sort(by: {$0.sellPrice < $1.sellPrice})
      
      self.copyMarkets.sort(by: {$0.1 < $1.1})
      self.copyUsdtMarkets.sort(by: {$0.1 < $1.1})
      self.copyBtcMarkets.sort(by: {$0.1 < $1.1})
      self.copyEthMarkets.sort(by: {$0.1 < $1.1})
      
    }
    else if sellSortButtonCounter == 2 {
      self.markets.sort(by: {$0.sellPrice > $1.sellPrice})
      self.usdtMarkets.sort(by: {$0.sellPrice > $1.sellPrice})
      self.btcMarkets.sort(by: {$0.sellPrice > $1.sellPrice})
      self.ethMarkets.sort(by: {$0.sellPrice > $1.sellPrice})
      
      self.copyMarkets.sort(by: {$0.1 > $1.1})
      self.copyUsdtMarkets.sort(by: {$0.1 > $1.1})
      self.copyBtcMarkets.sort(by: {$0.1 > $1.1})
      self.copyEthMarkets.sort(by: {$0.1 > $1.1})
      
    }
    sellSortButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortUsdtButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortBtcButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    sellSortEthButton.setTitle(sellTitleArray[sellSortButtonCounter], for: .normal)
    
    buySortButtonCounter = 0
    buySortButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortUsdtButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortBtcButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    buySortEthButton.setTitle(buyTitleArray[buySortButtonCounter], for: .normal)
    
    tableView.reloadData()
    usdtMarketsTable.reloadData()
    btcMarketsTable.reloadData()
    ethMarketsTable.reloadData()
    
  }
  
  @objc func handleButton(sender: CustomUIButton!) {
    if let title = sender.title {
      FirebaseService.shared.coin_market_button_tapped(name: title)
    }
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
    let marketSort = Defaults[.marketSort]
    let marketOrder = Defaults[.marketOrder]
    
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
    self.coinMarkets.removeAll()
    self.usdtMarkets.removeAll()
    self.btcMarkets.removeAll()
    self.ethMarkets.removeAll()
    self.tableView.reloadData()
    
    // for current coin price
    let tableTitle = currentCoin!
    coinRef = databaseReference.child(tableTitle)
    
    coinRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
      if let dict = snapshot.value as? [String : AnyObject] {
        if let currencyData = dict[GlobalValues.currency!] as? [String: Any] {
          let oldBtcPrice = self.currentCoinPrice
          self.currentCoinPrice = currencyData["price"] as! Double
          
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
                self.btcPriceLabel.theme_textColor = GlobalPicker.viewTextColor
              }, completion: nil)
            })
            
          }
          
          
          
          if let currencyMarkets = currencyData["markets"] as? [String: String] {
            self.coinMarkets = currencyMarkets
            self.setupCoinMarketRefs()
          }
        }
        
        if let usdtData = dict["USDT"] as? [String: Any] {
          if let usdtMarkets = usdtData["markets"] as? [String: String] {
            self.coinUsdtMarkets = usdtMarkets
            self.setupCoinUsdtMarketRefs()
          }
        }
        
        if let btcData = dict["BTC"] as? [String: Any] {
          if let btcMarkets = btcData["markets"] as? [String: String] {
            self.coinBtcMarkets = btcMarkets
            self.setupCoinBtcMarketRefs()
          }
        }
        
        if let ethData = dict["ETH"] as? [String: Any] {
          if let ethMarkets = ethData["markets"] as? [String: String] {
            self.coinEthMarkets = ethMarkets
            self.setupCoinEthMarketRefs()
          }
        }
        
      }
      
    })
    
    
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
        for index in 0..<self.copyUsdtMarkets.count {
          self.usdtMarkets[index].buyPrice = self.copyUsdtMarkets[index].0 * value
          self.usdtMarkets[index].sellPrice = self.copyUsdtMarkets[index].1 * value
        }
        for index in 0..<self.copyBtcMarkets.count {
          self.btcMarkets[index].buyPrice = self.copyBtcMarkets[index].0 * value
          self.btcMarkets[index].sellPrice = self.copyBtcMarkets[index].1 * value
        }
        for index in 0..<self.copyEthMarkets.count {
          self.ethMarkets[index].buyPrice = self.copyEthMarkets[index].0 * value
          self.ethMarkets[index].sellPrice = self.copyEthMarkets[index].1 * value
        }
        
      }
      self.tableView.reloadData()
      self.usdtMarketsTable.reloadData()
      self.btcMarketsTable.reloadData()
      self.ethMarketsTable.reloadData()
    }
  }
  
  func updatecurrentCoinPrice(_ value: Double) {
    self.btcPriceLabel.text = value.asCurrency
  }
  
  func populateFiatTable() {
    
    for coinMarket in coinMarkets {
      if let currentMarketInfo = marketInformation[coinMarket.key] {
        if let links = currentMarketInfo["links"] as? [String: Any] {
          if let url = links["Website"] as? String {
            addExchangeToTable(title: coinMarket.key, url: url, description: "", links: [])
          }
        }
      }
      
    }
  }
  
  func populateUsdtTable() {
    
    for coinUsdtMarket in coinUsdtMarkets {
      if let currentMarketInfo = marketInformation[coinUsdtMarket.key] {
        if let links = currentMarketInfo["links"] as? [String: Any] {
          addUsdtExchangeToTable(title: coinUsdtMarket.key, url: links["Website"] as! String, description: "", links: [])
        }
        
      }
    }
  }
  
  func populateBtcTable() {
    
    for coinBtcMarket in coinBtcMarkets {
      if let currentMarketInfo = marketInformation[coinBtcMarket.key] {
        if let links = currentMarketInfo["links"] as? [String: Any] {
          addBtcExchangeToTable(title: coinBtcMarket.key, url: links["Website"] as! String, description: "", links: [])
        }
        
      }
    }
  }
  
  func populateEthTable() {
    
    for coinEthMarket in coinEthMarkets {
      if let currentMarketInfo = marketInformation[coinEthMarket.key] {
        if let links = currentMarketInfo["links"] as? [String: Any] {
          addEthExchangeToTable(title: coinEthMarket.key, url: links["Website"] as! String, description: "", links: [])
        }
      }
    }
  }
  
  func addExchangeToTable(title: String, url: String, description: String, links: [String]) {
    self.markets.append(CoinMarket(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
    self.copyMarkets.append((0, 0))
  }
  
  func addUsdtExchangeToTable(title: String, url: String, description: String, links: [String]) {
    self.usdtMarkets.append(CoinMarket(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
    self.copyUsdtMarkets.append((0, 0))
  }
  
  func addBtcExchangeToTable(title: String, url: String, description: String, links: [String]) {
    self.btcMarkets.append(CoinMarket(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
    self.copyBtcMarkets.append((0, 0))
  }
  
  func addEthExchangeToTable(title: String, url: String, description: String, links: [String]) {
    self.ethMarkets.append(CoinMarket(title: title, siteLink: URL(string: url), buyPrice: 0, sellPrice: 0, description: description, links: links))
    self.copyEthMarkets.append((0, 0))
  }
  
  
  func flashBuyPriceLabel(cell: CoinMarketsTableViewCell, colour: UIColor) {
    UILabel.transition(with: cell.buyLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
      cell.buyLabel?.textColor = colour
    }, completion: { finished in
      UILabel.transition(with: cell.buyLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
        cell.buyLabel?.theme_textColor = GlobalPicker.viewTextColor
      }, completion: nil)
    })
  }
  
  func flashSellPriceLabel(cell: CoinMarketsTableViewCell, colour: UIColor) {
    UILabel.transition(with: cell.sellLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
      cell.sellLabel?.textColor = colour
    }, completion: { finished in
      UILabel.transition(with: cell.sellLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
        cell.sellLabel?.theme_textColor = GlobalPicker.viewTextColor
      }, completion: nil)
    })
  }
  
}

extension CoinMarketsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count: Int?
    
    if self.tableView == tableView {
      count = self.markets.count + self.liteMarkets.count
    }
    
    if self.usdtMarketsTable == tableView {
      count = self.usdtMarkets.count
    }
    
    if self.btcMarketsTable == tableView {
      count = self.btcMarkets.count
    }
    
    if self.ethMarketsTable == tableView {
      count = self.ethMarkets.count
    }
    
    return count!
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell?
    
    if self.tableView == tableView {
      tableHeightConstraint.constant = self.tableView.contentSize.height

      let market = self.markets[indexPath.row]
      let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? CoinMarketsTableViewCell
      
      cell!.siteLabel?.setTitle(market.title, for: .normal)
      cell!.siteLabel.url = market.siteLink
      cell!.siteLabel.title = market.title
      cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
      
      cell!.buyLabel?.text = market.buyPrice.asCurrency
      
      cell!.sellLabel?.text = market.sellPrice.asCurrency
      
      if indexPath.row == changedCell && changedTableView == tableView {
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
        changedTableView = nil
      }
      
      return cell!
    }
    
    if self.usdtMarketsTable == tableView {
      usdtTableHeightConstraint.constant = self.usdtMarketsTable.contentSize.height
      
      let cell = self.usdtMarketsTable.dequeueReusableCell(withIdentifier: "Cell") as? CoinMarketsTableViewCell
      let market = self.usdtMarkets[indexPath.row]
      cell!.siteLabel?.setTitle(market.title, for: .normal)
      cell!.siteLabel.url = market.siteLink
      cell!.siteLabel.title = market.title
      cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
      
      cell!.buyLabel?.text = market.buyPrice.asSelectedCurrency(currency: "USDT")
      
      cell!.sellLabel?.text = market.sellPrice.asSelectedCurrency(currency: "USDT")
      
      if indexPath.row == changedCell && changedTableView == usdtMarketsTable {
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
        changedTableView = nil
      }
      
      return cell!
    }
    
    if self.btcMarketsTable == tableView {
      btcTableHeightConstraint.constant = self.btcMarketsTable.contentSize.height

      let cell = self.btcMarketsTable.dequeueReusableCell(withIdentifier: "Cell") as? CoinMarketsTableViewCell
      let market = self.btcMarkets[indexPath.row]
      cell!.siteLabel?.setTitle(market.title, for: .normal)
      cell!.siteLabel.url = market.siteLink
      cell!.siteLabel.title = market.title
      cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
      
      cell!.buyLabel?.text = market.buyPrice.asBtcCurrency
      
      cell!.sellLabel?.text = market.sellPrice.asBtcCurrency
      
      if indexPath.row == changedCell && changedTableView == btcMarketsTable {
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
        changedTableView = nil
      }
      
      return cell!
    }
    
    if self.ethMarketsTable == tableView {
      ethTableHeightConstraint.constant = self.ethMarketsTable.contentSize.height

      let cell = self.ethMarketsTable.dequeueReusableCell(withIdentifier: "Cell") as? CoinMarketsTableViewCell
      let market = self.ethMarkets[indexPath.row]
      cell!.siteLabel?.setTitle(market.title, for: .normal)
      cell!.siteLabel.url = market.siteLink
      cell!.siteLabel.title = market.title
      cell!.siteLabel.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
      
      cell!.buyLabel?.text = market.buyPrice.asEthCurrency
      
      cell!.sellLabel?.text = market.sellPrice.asEthCurrency
      
      if indexPath.row == changedCell && changedTableView == ethMarketsTable {
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
        changedTableView = nil
      }
      
      return cell!
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    let row = indexPath.row
    if row % 2 == 0 {
      cell.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    }
    else {
      cell.theme_backgroundColor = GlobalPicker.alternateMarketRowColour
    }
  }
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    let destinationViewController = segue.destination
//    if let marketDetailController = destinationViewController as? MarketDetailViewController {
//      if let index = tableView.indexPathForSelectedRow?.row {
//        if let title = self.markets[index].title {
//          marketDetailController.market = title
//          marketDetailController.databaseChildTitle = self.coinMarkets[title]
//          marketDetailController.marketDescription = self.markets[index].description
//          marketDetailController.links = self.markets[index].links
//        }
//      }
//    }
//
//  }
  
}

