//
//  PortfolioTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 10/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Armchair
import SwiftyUserDefaults

class CryptoPortfolioTableViewController: UITableViewController {
  
  var portfolioName: String!
  
  var coin: String!
  var coinPrice: Double!
  
  // MARK: - Constants
  
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  
  let portfolioCellConstant = "portfolioBuyCell"
  let greenColour = UIColor.init(hex: "#2ecc71")
  let redColour = UIColor.init(hex: "#e74c3c")
  
  // MARK: - Variable initalization
  
  var parentController: CryptoPortfolioViewController!
  var portfolioData: [[String: Any]] = []
  var portfolioEntries: [PortfolioEntryModel] = []
  
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  // MARK: - UI Outlets
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    FirebaseService.shared.updateScreenName(screenName: "Crypto Portfolio", screenClass: "CryptoPortfolioViewController")
    
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone.current
    timeFormatter.dateFormat = "hh:mm a"
    timeFormatter.timeZone = TimeZone.current
    
    activityIndicator.addSubview(view)
    self.activityIndicator.hidesWhenStopped = true
    
    self.clearsSelectionOnViewWillAppear = true
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    portfolioEntries.removeAll()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    activityIndicator.startAnimating()
    self.initalizePortfolioEntries()
    self.activityIndicator.stopAnimating()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if portfolioEntries.count > 0 {
      parentController.containerViewHeightConstraint.constant = tableView.contentSize.height
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return portfolioEntries.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    dateFormatter.dateFormat = "dd/MM/YY"
    
    let portfolio = portfolioEntries[indexPath.row]
    var cell: PortfolioTableViewCell
    if portfolio.type == "buy" {
      cell = tableView.dequeueReusableCell(withIdentifier: portfolioCellConstant, for: indexPath) as! PortfolioTableViewCell
    }
    else if portfolio.type == "sell" {
      cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSellCell", for: indexPath) as! PortfolioTableViewCell
    }
    else if portfolio.type == "cryptoBuy" {
      cell = tableView.dequeueReusableCell(withIdentifier: portfolioCellConstant, for: indexPath) as! PortfolioTableViewCell
    }
    else {
      cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCryptoSellCell", for: indexPath) as! PortfolioTableViewCell
    }
    
    cell.coinLogoImage.loadSavedImage(coin: coin)
    
    cell.amountOfCoinsLabel.text = String(portfolio.amountOfCoins)
    
    if let percentageChange = portfolio.percentageChange {
      cell.percentageChange?.text = "\(percentageChange)%"
      if percentageChange > 0 {
        cell.percentageChangeView?.backgroundColor = greenColour
      }
      else if percentageChange == 0 {
        cell.percentageChangeView?.backgroundColor = UIColor.lightGray
      }
      else {
        cell.percentageChangeView?.backgroundColor = redColour
      }
    }
    
    if portfolio.type == "buy" {
      cell.amountOfCoinsLabel.textColor = greenColour
      if let date = portfolio.date {
        dateFormatter.dateFormat = "dd MMM, YYYY"
        timeFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        if let exchange = portfolio.exchange {
          cell.transactionInfoLabel.text = "Bought on \(dateString) via \(exchange) at \(timeString)"
        }
        else {
          cell.transactionInfoLabel.text = "Bought on \(dateString) at \(timeString)"
        }
      }
      
    }
    else if portfolio.type == "sell" {
      cell.amountOfCoinsLabel.textColor = redColour
      if let date = portfolio.date {
        dateFormatter.dateFormat = "dd MMM, YYYY"
        timeFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        if let exchange = portfolio.exchange {
          cell.transactionInfoLabel.text = "Sold on \(dateString) via \(exchange) at \(timeString)"
          
        }
        else {
          cell.transactionInfoLabel.text = "Sold on \(dateString) at \(timeString)"
        }
      }
    }
    else if portfolio.type == "cryptoBuy" {
      
      cell.amountOfCoinsLabel.textColor = greenColour
      if let date = portfolio.date, let tradingPair = portfolio.tradingPair {
        dateFormatter.dateFormat = "dd MMM, YYYY"
        timeFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        if let exchange = portfolio.exchange {
          cell.transactionInfoLabel.text = "Deposit due to sale of \(tradingPair) on \(dateString) via \(exchange) at \(timeString)"
        }
        else {
          cell.transactionInfoLabel.text = "Deposit due to sale of \(tradingPair) on \(dateString) at \(timeString)"
        }
      }
      
      if let cost = portfolio.costPerCoin, let amountOfCoins = portfolio.amountOfCoins, let fees = portfolio.fees {
        
        if portfolio.coin == "BTC" {
          cell.costPerCoinLabel.text = cost.asBtcCurrency
          cell.feesLabel?.text = fees.asBtcCurrency
        }
        else if portfolio.coin == "ETH" {
          cell.costPerCoinLabel.text = cost.asEthCurrency
          cell.feesLabel?.text = fees.asEthCurrency
        }
        else {
          cell.costPerCoinLabel.text = cost.asCurrency
          cell.feesLabel?.text = fees.asCurrency
        }
        
        cell.totalCostLabel.text = portfolio.totalCost.asCurrency
      }
      
      if let currentvalue = portfolio.currentValue {
        cell.currentValueLabel?.text = currentvalue.asCurrency
      }
      
      if let tradePair = portfolio.tradingPair {
        cell.tradingPairLabel.text = "\(tradePair)-\(coin!)"
      }
      
      return cell
      
    }
    else { // crypto sell
      cell.amountOfCoinsLabel.textColor = redColour
      if let date = portfolio.date, let tradingPair = portfolio.tradingPair {
        dateFormatter.dateFormat = "dd MMM, YYYY"
        timeFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        if let exchange = portfolio.exchange {
          cell.transactionInfoLabel.text = "Deduct due to purchase of \(tradingPair) on \(dateString) via \(exchange) at \(timeString)"
          
        }
        else {
          cell.transactionInfoLabel.text = "Deduct due to purchase of \(tradingPair) on \(dateString) at \(timeString)"
        }
      }
      
      if let cost = portfolio.costPerCoin, let amountOfCoins = portfolio.amountOfCoins, let fees = portfolio.fees {
        
        let total = (cost * amountOfCoins) - fees
        
        if portfolio.coin == "BTC" {
          cell.costPerCoinLabel.text = cost.asBtcCurrency
          cell.feesLabel?.text = fees.asBtcCurrency
        }
        else if portfolio.coin == "ETH" {
          cell.costPerCoinLabel.text = cost.asEthCurrency
          cell.feesLabel?.text = fees.asEthCurrency
        }
        else {
          cell.costPerCoinLabel.text = cost.asCurrency
          cell.feesLabel?.text = fees.asCurrency
        }
        
        cell.totalCostLabel.text = portfolio.totalCost.asCurrency
      }
      
      if let currentvalue = portfolio.currentValue {
        cell.currentValueLabel?.text = currentvalue.asCurrency
      }
      
      if let tradePair = portfolio.tradingPair {
        cell.tradingPairLabel.text = "\(tradePair)-\(coin!)"
      }
      return cell
    }
    
    if let cost = portfolio.costPerCoin, let amountOfCoins = portfolio.amountOfCoins, let fees = portfolio.fees {
      
      if portfolio.tradingPair == "BTC" {
        cell.costPerCoinLabel.text = cost.asBtcCurrency
        cell.feesLabel?.text = fees.asBtcCurrency
      }
      else if portfolio.tradingPair == "ETH" {
        cell.costPerCoinLabel.text = cost.asEthCurrency
        cell.feesLabel?.text = fees.asEthCurrency
      }
      else {
        cell.costPerCoinLabel.text = cost.asCurrency
        cell.feesLabel?.text = fees.asCurrency
      }
      
      cell.totalCostLabel.text = portfolio.totalCost.asCurrency
    }
    
    if let currentvalue = portfolio.currentValue {
      cell.currentValueLabel?.text = currentvalue.asCurrency
    }
    
    if let tradePair = portfolio.tradingPair {
      cell.tradingPairLabel.text = "\(coin!)-\(tradePair)"
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
      // delete item at indexPath
      let portfolioEntry = self.portfolioEntries[indexPath.row]
      self.portfolioEntries.remove(at: indexPath.row)
      self.deletePortfolioEntry(portfolioEntry: portfolioEntry)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.parentController.setTotalPortfolioValues()
    }
    
    return [delete]
  }
  
  func tableEmptyMessage() {
    let messageLabel = UILabel()
    messageLabel.text = "Add a transaction"
    messageLabel.theme_textColor = GlobalPicker.viewTextColor
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    messageLabel.sizeToFit()
    
    tableView.backgroundView = messageLabel
    tableView.backgroundView?.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

extension CryptoPortfolioTableViewController {
  // MARK: - Portfolio functions
  
  func addPortfolioEntry(portfolioEntry: [String: Any]) {
    Armchair.userDidSignificantEvent(true)
    self.portfolioData.append(portfolioEntry)
    savePortfolioEntry(coin: portfolioEntry["coin"] as! String, transaction: portfolioEntry)
  }
  
  func initalizePortfolioEntries() {
    
    if portfolioData.count == 0 {
      tableEmptyMessage()
    }
    else {
      for portfolio in portfolioData {
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"

        let type = portfolio["type"] as! String
        
        let dateString = portfolio["date"] as! String
        let date = dateFormatter.date(from: dateString)
        if type == "cryptoBuy" || type == "cryptoSell" {
          PortfolioEntryModel(type: portfolio["type"] as! String,
                              coin: coin,
                              tradingPair: portfolio["tradingPair"] as! String,
                              exchange: portfolio["exchange"] as! String,
                              costPerCoin: portfolio["costPerCoin"] as! Double,
                              amountOfCoins: portfolio["amountOfCoins"] as! Double,
                              fees: portfolio["fees"] as! Double,
                              date: date,
                              totalCost: portfolio["totalCost"] as! Double,
                              currentCoinPrice: self.coinPrice,
                              delegate: self)
        }
        else {
          
          PortfolioEntryModel(type: portfolio["type"] as! String,
                              coin: coin,
                              tradingPair: portfolio["tradingPair"] as! String,
                              exchange: portfolio["exchange"] as! String,
                              costPerCoin: portfolio["costPerCoin"] as! Double,
                              amountOfCoins: portfolio["amountOfCoins"] as! Double,
                              fees: portfolio["fees"] as! Double,
                              date: date,
                              totalCost: portfolio["totalCost"] as! Double,
                              currentCoinPrice: self.coinPrice,
                              delegate: self)
        }
      }
    }
  }
  
  // append portfolio entry to userdefaults stored portfolios, else create new data entry
  func savePortfolioEntry(coin: String, transaction: [String: Any]) {
    
    var allData = Defaults[.cryptoPortfolioData]
    if allData[portfolioName] == nil {
      allData[portfolioName] = [:]
    }
    if var currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
      var data: [String: [[String: Any]] ] = [:]
      if currentPortfolioData[coin] == nil {
        currentPortfolioData[coin] = []
      }
      for (dataCoin, transactions) in currentPortfolioData {
        data[dataCoin] = transactions
        if dataCoin == coin {
          data[dataCoin]?.append(transaction)
        }
      }
      allData[portfolioName] = data
      Defaults[.cryptoPortfolioData] = allData
      FirebaseService.shared.updatePortfolioData(databaseTitle: "CryptoData", data: allData)
      
      FirebaseService.shared.crypto_transaction_added(coin: coin)
      parentController.parentController.loadAllPortfolios(cryptoPortfolioData: data, fiatPortfolioData: nil)
      
    }
  }
  
  func deletePortfolioEntry(portfolioEntry: PortfolioEntryModel) {
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    
    var allData = Defaults[.cryptoPortfolioData]
    if let currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
      var data: [String: [[String: Any]] ] = [:]
      for (coin, transactions) in currentPortfolioData {
        // copy all transactions to new dict
        data[coin] = transactions
        
        if coin == portfolioEntry.coin {
          for (index, transaction) in data[coin]!.enumerated() {
            let type = transaction["type"] as? String
            let tradingPair = transaction["tradingPair"] as? String
            let exchange = transaction["exchange"] as? String
            let amountOfCoins = transaction["amountOfCoins"] as? Double
            
            var date: Date!
            if let dateString = transaction["date"] as? String {
              date = dateFormatter.date(from: dateString)
            }
            if portfolioEntry.type == type &&
              portfolioEntry.tradingPair == tradingPair &&
              portfolioEntry.exchange == exchange &&
              portfolioEntry.amountOfCoins == amountOfCoins &&
              portfolioEntry.date == date {
              
              if type == "buy" {
                parentController.subtractTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.costPerCoin, currentValue: portfolioEntry.currentValue)
              }
              else if type == "sell" {
                parentController.subtractSellTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.costPerCoin, currentValue: portfolioEntry.currentValue)
              }
              
              data[coin]!.remove(at: index)
              break
            }
          }
        }
      }
      
      if portfolioEntries.count == 0 {
        tableEmptyMessage()
      }
      allData[portfolioName] = data
      Defaults[.cryptoPortfolioData] = allData
      FirebaseService.shared.deletePortfolioData(databaseTitle: "CryptoData", data: allData)
      
      parentController.parentController.loadAllPortfolios(cryptoPortfolioData: data, fiatPortfolioData: nil)
      
    }
  }
}

extension CryptoPortfolioTableViewController: PortfolioEntryDelegate {
  
  func dataLoaded(portfolioEntry: PortfolioEntryModel) {
    if portfolioEntry.type == "buy" || portfolioEntry.type == "cryptoBuy" {
      parentController.addTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.totalCost, currentValue: portfolioEntry.currentValue)
    }
    else if portfolioEntry.type == "sell" || portfolioEntry.type == "cryptoSell" {
      parentController.addSellTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.totalCost, currentValue: portfolioEntry.currentValue)
    }
    portfolioEntries.append(portfolioEntry)
//    print(portfolioEntries)
//    print(portfolioEntry)
    for portfolio in portfolioEntries {
      print(portfolio.date)
    }
    portfolioEntries = portfolioEntries.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
    
    tableView.reloadData()
  }
}

extension Date {
  func daysBetweenDate(toDate: Date) -> Int {
    let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
    return components.day ?? 0
  }
}
