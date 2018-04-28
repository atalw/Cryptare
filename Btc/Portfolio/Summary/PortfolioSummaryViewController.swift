//
//  PortfolioSummaryViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
import SwiftyJSON

class PortfolioSummaryViewController: UIViewController {
  
  lazy var currentThemeIndex: Int = {
    return Defaults[.currentThemeIndex]
  }()
  
  var globalCoins: [String] = []
  var globalCurrencies: [String] = []
  
  var currency: String! {
    didSet {
      loadAllPortfolios(cryptoPortfolioData: cryptoPortfolioData, fiatPortfolioData: fiatPortfolioData)
    }
  }
  
  var portfolioName: String!
  var cryptoPortfolioData: [String: [[String: Any]] ]!
  var fiatPortfolioData: [String: [[String: Any]] ]!
  
  let defaults = UserDefaults.standard
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  
  let greenColour = UIColor.init(hex: "#2ecc71")
  let redColour = UIColor.init(hex: "#e74c3c")
  
  var cryptoDict: [String: [[String: Any]] ] = [:]
  var fiatDict: [String: [[String: Any]]] = [:]
  
  var summary: [String: [String: Double] ] = [:]
  var yesterdayCoinValues: [String: Double] = [:]
  
  var coins: [String] = []
  var currencies: [String] = []
  
  var databaseRef: DatabaseReference!
  var coinRefs: [DatabaseReference] = []
  
  lazy var refreshControl: UIRefreshControl = {
    
    let refreshControl = UIRefreshControl()
    
    refreshControl.addTarget(self, action:
      #selector(handleRefresh(_:)),
                             for: UIControlEvents.valueChanged)
    
    refreshControl.theme_tintColor = GlobalPicker.viewTextColor
    
    return refreshControl
  }()
  
  @IBOutlet weak var summaryTitleDescLabel: UILabel! {
    didSet {
      summaryTitleDescLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var option24hrButton: UIButton! {
    didSet {
      option24hrButton.isSelected = true
      option24hrButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
      option24hrButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
    }
  }
  @IBOutlet weak var optionAllTimeButton: UIButton! {
    didSet {
      optionAllTimeButton.isSelected = false
      
      optionAllTimeButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
      optionAllTimeButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
    }
  }
  
  @IBOutlet weak var summaryView: UIView! {
    didSet {
      summaryView.theme_backgroundColor = GlobalPicker.summaryViewBackgroundColor
    }
  }
  @IBOutlet weak var currentPortfolioValueLabel: UILabel! {
    didSet {
      currentPortfolioValueLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var totalInvestedLabel: UILabel! {
    didSet {
      totalInvestedLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var totalPercentageChangeLabel: UILabel! {
    didSet {
      totalPercentageChangeLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var totalPriceChangeLabel: UILabel! {
    didSet {
      totalPriceChangeLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var totalPortfolioDescLabel: UILabel! {
    didSet {
      totalPortfolioDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  @IBOutlet weak var percentageChangeDescLabel: UILabel! {
    didSet {
      percentageChangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
      
    }
  }
  
  @IBOutlet weak var totalInvestDescLabel: UILabel! {
    didSet {
      totalInvestDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var priceChangeDescLabel: UILabel! {
    didSet {
      priceChangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  @IBOutlet weak var addCoinButton: UIButton! {
    didSet {
      addCoinButton.theme_backgroundColor = GlobalPicker.addCoinButton
    }
  }
  
  @IBOutlet weak var scrollView: UIScrollView! {
    didSet {
      self.scrollView.addSubview(self.refreshControl)
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    FirebaseService.shared.updateScreenName(screenName: "Portfolio Summary", screenClass: "PortfolioSummaryViewController")
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    for (symbol, name) in GlobalValues.coins {
      globalCoins.append(symbol)
    }
    
    for (_, symbol, _, _) in GlobalValues.countryList {
      globalCurrencies.append(symbol)
    }
    
    currency = GlobalValues.currency!
    
    dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
    dateFormatter.timeZone = TimeZone.current
    
    timeFormatter.dateFormat = "hh:mm a"
    
    tableView.delegate = self
    tableView.dataSource = self
    
    yesterdayCoinValues = [:]
    
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    currentPortfolioValueLabel.text = 0.0.asCurrency
    totalInvestedLabel.text = 0.0.asCurrency
    totalPriceChangeLabel.text = 0.0.asCurrency
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    currentThemeIndex = Defaults[.currentThemeIndex]
    
    databaseRef.removeAllObservers()
    
    for coinRef in coinRefs {
      coinRef.removeAllObservers()
    }
    
    if coins.count == 0 {
      tableView.reloadData()
      //            updateSummaryLabels(portfolioName: portfolioName)
      let messageLabel = UILabel()
      messageLabel.text = "Add a coin"
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      tableView.backgroundView = messageLabel
    }
    else {
      tableView.backgroundView = nil
      
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidLayoutSubviews() {
    if coins.count == 0 && currencies.count == 0 {
      tableViewHeightConstraint.constant = 500
    }
    else {
      tableViewHeightConstraint.constant = tableView.contentSize.height + 50
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    databaseRef.removeAllObservers()
    
    for coinRef in coinRefs {
      coinRef.removeAllObservers()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  func loadAllPortfolios(cryptoPortfolioData: [String: [[String: Any]]]?, fiatPortfolioData: [String: [[String: Any]]]?) {
    databaseRef = Database.database().reference()
    
    initalizePortfolioEntries(cryptoPortfolioData: cryptoPortfolioData, fiatPortfolioData: fiatPortfolioData)
  }
  
  func updateCurrency(currency: String) {
    defer {
      self.currency = currency
    }
  }
  
  func calculateCostFromDate(dateString: String, completionHandler: @escaping (Double) -> ()) {
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from: dateString)
    let unixTime = Int((date?.timeIntervalSince1970)!)
    let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=BTC&tsyms=\(GlobalValues.currency!)&ts=\(unixTime)")!
    Alamofire.request(url).responseJSON(completionHandler: { response in
      
      let json = JSON(data: response.data!)
      if let price = json["BTC"][self.currency].double {
        completionHandler(price)
      }
    })
  }
  
  func initalizePortfolioEntries(cryptoPortfolioData: [String: [[String: Any]]]?, fiatPortfolioData: [String: [[String: Any]]]?) {
    
    if cryptoPortfolioData != nil {
      cryptoDict = [:]
      cryptoDict = cryptoPortfolioData!
      coins = []
      for coin in cryptoDict.keys {
        coins.append(coin)
      }
    }
    
    if fiatPortfolioData != nil {
      fiatDict = [:]
      fiatDict = fiatPortfolioData!
      currencies = []
      for currency in fiatDict.keys {
        currencies.append(currency)
      }
    }
        
    calculatePortfolioSummary(portfolioName: portfolioName, cryptoDict: cryptoDict, fiatDict: fiatDict)
    
  }
  
  func calculatePortfolioSummary(portfolioName: String, cryptoDict: [String: [[String: Any]]], fiatDict: [String: [[String: Any]]]) {
    
    for (coin, transactions) in cryptoDict {
      
      summary[coin] = [:]
      summary[coin]!["amountOfCoins"] = 0.0
      summary[coin]!["costPerCoin"] = 0.0
      summary[coin]!["totalCost"] = 0.0
      summary[coin]!["coinMarketValue"] = 0.0 // market value of 1 coin
      summary[coin]!["holdingsMarketValue"] = 0.0 // market value of holdings
      summary[coin]!["coinValueYesterday"] = 0.0
      summary[coin]!["holdingsValueYesterday"] = 0.0
      
      for (index, trans) in transactions.enumerated() {
        let tradingPair = trans["tradingPair"] as! String
        let type = trans["type"] as! String

        if type == "cryptoBuy" || type == "cryptoSell" {
          if globalCoins.contains(tradingPair) {
            let amountOfCoins = trans["amountOfCoins"] as! Double
            let costPerCoin = trans["costPerCoin"] as! Double
            let fees = trans["fees"] as! Double
            let fiatPrice = trans["fiatPrice"] as! Double
            let fiat = trans["fiat"] as! String
            
            var costPerCoinFiat = 0.0
            var totalCostFiat = 0.0
            if fiat == self.currency {
              costPerCoinFiat = costPerCoin * fiatPrice
              totalCostFiat = (amountOfCoins - fees) * fiatPrice
              self.updateSummaryWithCryptoTransaction(coin: coin, type: type, amountOfCoins: amountOfCoins, costPerCoin: costPerCoinFiat, totalCost: totalCostFiat)
              
              self.cryptoDict[coin]![index]["totalCost"] = totalCostFiat
            }
            else {
              self.getExchangeRate(symbol: self.currency, base: fiat, completion: { success, exchangeRate in
                if success {
                  costPerCoinFiat = (costPerCoin * fiatPrice) * exchangeRate
                  totalCostFiat = (((amountOfCoins * costPerCoin) - fees) * fiatPrice) * exchangeRate
                  self.updateSummaryWithCryptoTransaction(coin: coin, type: type, amountOfCoins: amountOfCoins, costPerCoin: costPerCoinFiat, totalCost: totalCostFiat)
                  
                  self.cryptoDict[coin]![index]["totalCost"] = totalCostFiat
                }
              })
            }
          }
        }
        else {
          if tradingPair != GlobalValues.currency! {
            // check if trading pair is a fiat currency
            if globalCurrencies.contains(tradingPair) {
              self.getExchangeRate(symbol: self.currency, base: tradingPair, completion: { success, exchangeRate in
                if success {
                  let type = trans["type"] as! String
                  let amountOfCoins = trans["amountOfCoins"] as! Double
                  let costPerCoin = trans["costPerCoin"] as! Double * exchangeRate
                  let fees = (trans["fees"] as! Double) * exchangeRate
                  let totalCost = (trans["totalCost"] as! Double) * exchangeRate
                  
                  self.updateSummaryWithCryptoTransaction(coin: coin, type: type, amountOfCoins: amountOfCoins, costPerCoin: costPerCoin, totalCost: totalCost)
                  
                  // update crypto dict to show converted in crypto table VC
                  self.cryptoDict[coin]![index]["costPerCoin"] = costPerCoin
                  self.cryptoDict[coin]![index]["fees"] = fees
                  self.cryptoDict[coin]![index]["totalCost"] = totalCost
                }
              })
            }
            else {
              // check if trans fiat value is same as current fiat
              // else apply exchange rate
              
              let fiat = trans["fiat"] as! String
              
              if fiat != self.currency {
                self.getExchangeRate(symbol: self.currency, base: fiat, completion: { success, exchangeRate in
                  if success {
                    let type = trans["type"] as! String
                    let amountOfCoins = trans["amountOfCoins"] as! Double
                    let costPerCoin = trans["costPerCoin"] as! Double
                    var totalCost = trans["totalCost"] as! Double
                    
                    totalCost = totalCost * exchangeRate
                    self.updateSummaryWithCryptoTransaction(coin: coin, type: type, amountOfCoins: amountOfCoins, costPerCoin: costPerCoin, totalCost: totalCost)
                    
                    self.cryptoDict[coin]![index]["totalCost"] = totalCost
                  }
                })
              }
              else {
                self.cryptoTransactionSummary(coin: coin, trans: trans)
              }
            }
          }
          else {
            self.cryptoTransactionSummary(coin: coin, trans: trans)
          }
        }
      }
      
      coinRefs.append(databaseRef.child(coin).child("Data").child(self.currency))
      let index = coinRefs.count - 1
      
      coinRefs[index].observeSingleEvent(of: .value, with: {(snapshot) -> Void in
        if let cryptoDict = snapshot.value as? [String : AnyObject] {
          if let price = cryptoDict["price"] as? Double {
            self.summary[coin]!["coinMarketValue"] = price
            self.summary[coin]!["holdingsMarketValue"] = self.summary[coin]!["amountOfCoins"]! * price
            self.tableView.reloadData()
          }
        }
      })
    }
    
    for currency in fiatDict.keys {
      summary[currency] = [:]
      summary[currency]!["amount"] = 0.0
      summary[currency]!["deposited"] = 0.0
      
      for (index, entry) in fiatDict[currency]!.enumerated() {
        if currency != GlobalValues.currency! {
          // check if trading pair is a fiat currency
          for (_, symbol, _, _) in GlobalValues.countryList {
            if symbol == currency {
              self.getExchangeRate(symbol: self.currency, base: currency, completion: { success, exchangeRate in
                if success {
                  let type = entry["type"] as! String
                  let amount = (entry["amount"] as! Double) * exchangeRate
                  let fees = (entry["fees"] as! Double) * exchangeRate
                  
                  self.updateSummaryWithFiatTransaction(currency: currency, type: type, amount: amount, fees: fees)
                  
                  self.fiatDict[currency]![index]["amount"] = amount
                  self.fiatDict[currency]![index]["fees"] = fees
                  DispatchQueue.main.async {
                    self.tableView.reloadData()
                  }
                }
              })
            }
          }
        }
        else {
          let type = entry["type"] as! String
          let amount = entry["amount"] as! Double
          let fees = entry["fees"] as! Double
          
          updateSummaryWithFiatTransaction(currency: currency, type: type, amount: amount, fees: fees)
        }
      }
    }
    getCoinValueYesterday()
  }
    
  func cryptoTransactionSummary(coin: String, trans: [String: Any]) {
    let type = trans["type"] as! String
    let amountOfCoins = trans["amountOfCoins"] as! Double
    let costPerCoin = trans["costPerCoin"] as! Double
    let totalCost = trans["totalCost"] as! Double
    
    updateSummaryWithCryptoTransaction(coin: coin, type: type, amountOfCoins: amountOfCoins, costPerCoin: costPerCoin, totalCost: totalCost)
  }
  
  func updateSummaryWithCryptoTransaction(coin: String, type: String, amountOfCoins: Double, costPerCoin: Double, totalCost: Double) {
    
    if type == "buy" || type == "cryptoBuy" {
      summary[coin]!["amountOfCoins"] = summary[coin]!["amountOfCoins"]! + amountOfCoins
      summary[coin]!["costPerCoin"] = summary[coin]!["costPerCoin"]! + costPerCoin
      summary[coin]!["totalCost"] =  summary[coin]!["totalCost"]! + totalCost
    }
    else if type == "sell" || type == "cryptoSell" {
      summary[coin]!["amountOfCoins"] = summary[coin]!["amountOfCoins"]! - amountOfCoins
      summary[coin]!["costPerCoin"] = summary[coin]!["costPerCoin"]! - costPerCoin
      summary[coin]!["totalCost"] =  summary[coin]!["totalCost"]! - totalCost
    }
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  func updateSummaryWithFiatTransaction(currency: String, type: String, amount: Double, fees: Double) {
    
    if type == "deposit" {
      summary[currency]!["amount"] = summary[currency]!["amount"]! + amount - fees
      summary[currency]!["deposited"] = summary[currency]!["deposited"]! + amount
    }
    else if type == "withdraw" {
      summary[currency]!["amount"] = summary[currency]!["amount"]! - amount - fees
    }
  }
  
  func getCoinValueYesterday() {
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let yesterday = Int(Date().timeIntervalSince1970 - (24*60*60))
    for coin in coins {
      let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=\(coin)&tsyms=\(GlobalValues.currency!)&ts=\(yesterday)")!
      
      Alamofire.request(url).responseJSON(completionHandler: { response in
        
        let json = JSON(data: response.data!)
        if let price = json[coin][self.currency].double {
          self.summary[coin]!["coinValueYesterday"] = price
          self.summary[coin]!["holdingsValueYesterday"] = price * self.summary[coin]!["amountOfCoins"]!
          self.tableView.reloadData()
        }
      })
    }
  }
  
  func updateSummaryLabels() {
    var currentPortfolioValue = 0.0
    var totalInvested = 0.0
    var yesterdayPortfolioValue = 0.0
    
    currentPortfolioValueLabel.text = 0.asCurrency
    totalInvestedLabel.text = 0.asCurrency
    
    totalPercentageChangeLabel.text = "\(0.00) %"
    totalPriceChangeLabel.text = 0.asCurrency
    
    for coin in coins {
      if let yesterdayPrice = self.summary[coin]!["coinValueYesterday"],
        let amountOfCoins = self.summary[coin]!["amountOfCoins"] {
        
        self.summary[coin]!["holdingsValueYesterday"] =  yesterdayPrice * amountOfCoins
        
        currentPortfolioValue = currentPortfolioValue + summary[coin]!["holdingsMarketValue"]!
        totalInvested = totalInvested + summary[coin]!["totalCost"]!
        yesterdayPortfolioValue = yesterdayPortfolioValue + summary[coin]!["holdingsValueYesterday"]!
        
      }
    }
    
    for currency in currencies {
      currentPortfolioValue = currentPortfolioValue + summary[currency]!["amount"]!
      yesterdayPortfolioValue = yesterdayPortfolioValue + summary[currency]!["amount"]!
    }
    
    var priceChange: Double = 0
    var percentageChange: Double = 0
    
    if option24hrButton.isSelected {
      priceChange = currentPortfolioValue - yesterdayPortfolioValue
      percentageChange = priceChange / yesterdayPortfolioValue * 100
    }
    else if optionAllTimeButton.isSelected {
      priceChange = currentPortfolioValue - totalInvested
      percentageChange = priceChange / totalInvested * 100
    }
    
    var colour: UIColor
    
    if percentageChange > 0 {
      colour = greenColour
    }
    else if percentageChange < 0 {
      colour = redColour
    }
    else {
      colour = UIColor.black
    }
    
    currentPortfolioValueLabel.text = currentPortfolioValue.asCurrency
    totalInvestedLabel.text = totalInvested.asCurrency
    
    if !percentageChange.isNaN && !percentageChange.isInfinite {
      let roundedPercentageChange = Double(round(percentageChange*100)/100)
      
      totalPercentageChangeLabel.text = "\(roundedPercentageChange) %"
      totalPriceChangeLabel.text = priceChange.asCurrency
      
      totalPercentageChangeLabel.textColor = colour
      totalPriceChangeLabel.textColor = colour
    }
    
  }
  
  func getExchangeRate(symbol: String, base: String, completion: @escaping (_ success : Bool, _ exchangeRate: Double) -> ()) {
    var exchangeRate: Double = 1
    
    let exchangeURL = URL(string: "https://api.fixer.io/latest?symbols=\(symbol)&base=\(base)")!
    let exchangeTask = URLSession.shared.dataTask(with: exchangeURL) { data, response, error in
      guard error == nil else {
        return
      }
      guard let data = data else {
        return
      }
      do {
        if let rate = JSON(data:data)["rates"][symbol].double {
          exchangeRate = rate
        }
        completion(true, exchangeRate)
      }
    }
    exchangeTask.resume()
  }
  
  @IBAction func optionAllTimeTapped(_ sender: Any) {
    optionAllTimeButton.isSelected = true
    option24hrButton.isSelected = false
    updateSummaryLabels()
    tableView.reloadData()
  }
  
  @IBAction func option24hrTapped(_ sender: Any) {
    optionAllTimeButton.isSelected = false
    option24hrButton.isSelected = true
    updateSummaryLabels()
    tableView.reloadData()
  }
  
  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    
    initalizePortfolioEntries(cryptoPortfolioData: [:], fiatPortfolioData: [:])
    self.tableView.reloadData()
      
    initalizePortfolioEntries(cryptoPortfolioData: cryptoPortfolioData, fiatPortfolioData: fiatPortfolioData)
    self.tableView.reloadData()
    
    updateSummaryLabels()
    
    refreshControl.endRefreshing()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let destinationVc = segue.destination
    if let addCoinVc = destinationVc as? AddCoinTableViewController {
      addCoinVc.parentController = self
    }
    else if let cryptoPortfolioVC = destinationVc as? CryptoPortfolioViewController {
      cryptoPortfolioVC.parentController = self
    }
  }
  
  
}

extension PortfolioSummaryViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if cryptoDict.count > 0 && fiatDict.count > 0 {
      return 2
    }
    else if (cryptoDict.count == 0 && fiatDict.count > 0) || (cryptoDict.count > 0 && fiatDict.count == 0) {
      return 1
    }
    else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 && cryptoDict.count > 0 {
      return "Cryptocurrencies"
    }
    else {
      return "Fiat currencies"
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = 0
    if section == 0 && cryptoDict.count > 0 {
      count = cryptoDict.count
    }
    else {
      count = fiatDict.count
    }
    return count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    updateSummaryLabels()
    
    if indexPath.section == 0 && cryptoDict.count > 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSummaryCell") as? PortfolioSummaryTableViewCell
      
      cell!.selectionStyle = .none
      
      let coin = coins[indexPath.row]
      
      cell!.coinSymbolLabel.text = "\(coin)"
      cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
      
      cell!.coinImage.loadSavedImage(coin: coin)
      
      for (symbol, name) in GlobalValues.coins {
        if symbol == coin {
          cell!.coinNameLabel.text = name
        }
      }
      
      if let amountOfCoins = self.summary[coin]!["amountOfCoins"] {
        cell!.coinHoldingsLabel.text = "\(amountOfCoins) \(coin)"
        cell!.coinHoldingsLabel.adjustsFontSizeToFitWidth = true
        
        if let currentCoinMarketValue = self.summary[coin]!["coinMarketValue"] {
          self.summary[coin]!["holdingsMarketValue"] =  amountOfCoins * currentCoinMarketValue
          
          let holdingsMarketValue = summary[coin]!["holdingsMarketValue"]!
          cell!.coinCurrentValueLabel.text = holdingsMarketValue.asCurrency
          cell!.coinCurrentValueLabel.adjustsFontSizeToFitWidth = true
          
          var percentageChange: Double! = 0
          var priceChange: Double! = 0
          
          if option24hrButton.isSelected {
            let holdingsValueYesterday = summary[coin]!["holdingsValueYesterday"]!
            priceChange = holdingsMarketValue - holdingsValueYesterday
            
            percentageChange = priceChange / holdingsValueYesterday * 100
          }
          else if optionAllTimeButton.isSelected {
            let totalCost = summary[coin]!["totalCost"]!
            priceChange = holdingsMarketValue - totalCost
            
            percentageChange = priceChange / totalCost * 100
          }
          
          
          var colour: UIColor
          
          if percentageChange > 0 {
            colour = greenColour
          }
          else if percentageChange < 0 {
            colour = redColour
          }
          else {
            colour = UIColor.black
          }
          
          if !percentageChange.isNaN && !percentageChange.isInfinite {
            let roundedPercentage = Double(round(percentageChange*100)/100)
            
            cell!.changePercentageLabel.text = "\(roundedPercentage) %"
            cell!.changeCostLabel.text = priceChange.asCurrency
            
            cell!.changePercentageLabel.textColor = colour
            cell!.changeCostLabel.textColor = colour
          }
        }
      }
      
      cell!.changePercentageLabel.adjustsFontSizeToFitWidth = true
      cell!.changeCostLabel.adjustsFontSizeToFitWidth = true
      
      return cell!
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioFiatSummaryCell") as! PortfolioFiatSummaryTableViewCell
      
      cell.selectionStyle = .none
      
      let currency = currencies[indexPath.row]
      
      cell.currencyLogoImage.image = UIImage(named: currency.lowercased())
      cell.currencySymbolLabel.text = currency
      
      for (_, symbol, _, name) in GlobalValues.countryList {
        if symbol == currency {
          cell.currencyNameLabel.text = name
        }
      }
      
      if let holdingsMarketValue = summary[currency]?["amount"] {
        cell.holdingsLabel.text = holdingsMarketValue.asCurrency
        cell.holdingsLabel.adjustsFontSizeToFitWidth = true
      }
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    
    if section == 0 && cryptoDict.count > 0 {
      let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! CryptoPortfolioViewController
      
      let coin = coins[indexPath.row]
      targetViewController.coin = coin
      targetViewController.portfolioName = portfolioName
      targetViewController.portfolioData = cryptoDict[coin]!
      targetViewController.coinPrice = self.summary[coin]!["coinMarketValue"]
      targetViewController.parentController = self
      
      self.navigationController?.pushViewController(targetViewController, animated: true)
    }
    else {
      let targetViewController = storyboard?.instantiateViewController(withIdentifier: "fiatPortfolioViewController") as! FiatPortfolioViewController
      
      let currency = currencies[indexPath.row]
      targetViewController.currency = currency
      targetViewController.portfolioName = portfolioName
      targetViewController.portfolioData = fiatDict[currency]!
      targetViewController.parentController = self
      
      self.navigationController?.pushViewController(targetViewController, animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
  func newCoinAdded(coin: String) {
    let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! CryptoPortfolioViewController
    
    databaseRef.child(coin).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
      if let dict = snapshot.value as? [String : AnyObject] {
        let price = dict[self.currency]!["price"] as! Double
        targetViewController.coinPrice = price
      }
    })
    
    targetViewController.coin = coin
    targetViewController.portfolioName = portfolioName
    targetViewController.parentController = self
    if let data = cryptoDict[coin] {
      targetViewController.portfolioData = data
    }
    else {
      targetViewController.portfolioData = []
    }
    self.navigationController?.pushViewController(targetViewController, animated: true)
  }
  
  func newCurrencyAdded(currency: String) {
    let targetViewController = storyboard?.instantiateViewController(withIdentifier: "fiatPortfolioViewController") as! FiatPortfolioViewController
    
    targetViewController.currency = currency
    targetViewController.portfolioName = portfolioName
    targetViewController.portfolioName = portfolioName
    targetViewController.parentController = self
    
    if let data = fiatDict[currency] {
      targetViewController.portfolioData = data
    }
    else {
      targetViewController.portfolioData = []
    }
    
    self.navigationController?.pushViewController(targetViewController, animated: true)
  }
}
