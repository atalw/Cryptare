//
//  FiatPortfolioTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class FiatPortfolioTableViewController: UITableViewController {
  
  var parentController: FiatPortfolioViewController!
  
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  let calendar = Calendar.current
  
  var currency: String!
  
  var portfolioData: [[String: Any]] = []
  var portfolioName: String!
  
  var portfolioEntries: [FiatTransactionEntryModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    self.clearsSelectionOnViewWillAppear = true
    
    dateFormatter.dateFormat = "dd MMM, YYYY"
    timeFormatter.dateFormat = "hh:mm a"
    dateFormatter.timeZone = TimeZone.current
    timeFormatter.timeZone = TimeZone.current
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    portfolioEntries.removeAll()
    
    self.initalizePortfolioEntries()
    
    portfolioEntries = portfolioEntries.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
    tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseService.shared.updateScreenName(screenName: "Fiat Portfolio", screenClass: "FiatPortfolioViewController")
  }
  
  override func viewWillLayoutSubviews() {
    if portfolioEntries.count > 0 {
      parentController.containerViewHeight.constant = tableView.contentSize.height
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return portfolioEntries.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    dateFormatter.dateFormat = "dd MMM, YYYY"
    timeFormatter.dateFormat = "hh:mm a"
    
    let entry = portfolioEntries[indexPath.row]
    var cell: FiatPortfolioTableViewCell
    
    cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! FiatPortfolioTableViewCell
    
    
    
    cell.amountLabel.text = entry.amount.asCurrency
    cell.feesLabel.text = entry.fees.asCurrency
    
    if let date = entry.date {
      cell.dateLabel.text = dateFormatter.string(from: date)
      cell.timeLabel.text = timeFormatter.string(from: date)
    }
    
    
    if entry.type == "deposit" {
      cell.transactionTypeLabel.text = "Deposited via \(entry.exchange!)"
    }
    else {
      cell.transactionTypeLabel.text = "Withdrawn via \(entry.exchange!)"
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
  
}

extension FiatPortfolioTableViewController {
  
  func addPortfolioEntry(portfolioEntry: [String: Any]) {
    
    self.portfolioData.append(portfolioEntry)
    
    let amount = portfolioEntry["amount"] as! Double
    let fees = portfolioEntry["fees"] as! Double
    
    if portfolioEntry["type"] as! String == "deposit" {
      parentController.updateTotalDeposited(value: amount)
      parentController.updateCurrentAvailable(value: amount-fees)
    }
    else if portfolioEntry["type"] as! String == "withdraw" {
      parentController.updateTotalWithdrawn(value: amount)
    }
    savePortfolioEntry(portfolioEntry: portfolioEntry)
    tableView.reloadData()
  }
  
  func initalizePortfolioEntries() {
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    
    if portfolioData.count == 0 {
      tableEmptyMessage()
    }
    else {
      for portfolio in portfolioData {
        let dateString = portfolio["date"] as! String
        let date = dateFormatter.date(from: dateString)!
        let entry = FiatTransactionEntryModel(currency: currency,
                                              type: portfolio["type"] as! String,
                                              exchange: portfolio["exchange"] as! String,
                                              amount: portfolio["amount"] as! Double,
                                              fees: portfolio["fees"] as! Double,
                                              date: date)
        portfolioEntries.append(entry)
        
        if entry.type == "deposit" {
          parentController.updateCurrentAvailable(value: entry.amount-entry.fees)
          parentController.updateTotalDeposited(value: entry.amount)
        }
        else if entry.type == "withdraw" {
          parentController.updateTotalWithdrawn(value: entry.amount)
          parentController.updateCurrentAvailable(value: -(entry.amount))
          
        }
      }
    }
    
    tableView.reloadData()
    
  }
  
  // append portfolio entry to userdefaults stored portfolios, else create new data entry
  func savePortfolioEntry(portfolioEntry: [String: Any]) {
    
    let transaction = ["type": portfolioEntry["type"]!,
                       "exchange": portfolioEntry["exchange"]!,
                       "amount": portfolioEntry["amount"]!,
                       "fees": portfolioEntry["fees"]!,
                       "date": portfolioEntry["date"]!]
    
    var allData = Defaults[.fiatPortfolioData]
    if allData[portfolioName] == nil {
      allData[portfolioName] = [:]
    }
    if var currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
      var data: [String: [[String: Any]] ] = [:]
      if currentPortfolioData[currency] == nil {
        currentPortfolioData[currency] = []
      }
      for (currency, transactions) in currentPortfolioData {
        data[currency] = transactions
        if currency == self.currency {
          data[currency]?.append(transaction)
        }
      }
      allData[portfolioName] = data
      Defaults[.fiatPortfolioData] = allData
      
      FirebaseService.shared.updatePortfolioData(databaseTitle: "FiatData", data: allData)
      
      FirebaseService.shared.fiat_transaction_added(currency: currency)
      parentController.parentController.loadAllPortfolios(cryptoPortfolioData: nil, fiatPortfolioData: data)
    }
  }
  
  func deletePortfolioEntry(portfolioEntry: FiatTransactionEntryModel) {
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"

    var allData = Defaults[.fiatPortfolioData]
    if let currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
      var data: [String: [[String: Any]] ] = [:]
      for (currency, transactions) in currentPortfolioData {
        // copy all transactions to new dict
        data[currency] = transactions
        if currency == portfolioEntry.currency {
          for (index, transaction) in data[currency]!.enumerated() {
            let type = transaction["type"] as? String
            let exchange = transaction["exchange"] as? String
            let amount = transaction["amount"] as! Double
            let fees = transaction["fees"] as! Double
            var date: Date!
            if let dateString = transaction["date"] as? String {
              date = dateFormatter.date(from: dateString)
            }

            if portfolioEntry.type == type &&
              portfolioEntry.exchange == exchange &&
              portfolioEntry.date == date {
              
              if type == "deposit" {
                parentController.updateCurrentAvailable(value: -(amount-fees))
                parentController.updateTotalDeposited(value: -(amount))
              }
              else if type == "withdraw" {
                parentController.updateTotalWithdrawn(value: -(amount))
                parentController.updateCurrentAvailable(value: amount)
              }
              data[currency]!.remove(at: index)
              break
            }
          }
        }
      }
      
      if portfolioEntries.count == 0 {
        tableEmptyMessage()
      }
      
      allData[portfolioName] = data
      Defaults[.fiatPortfolioData] = allData
      FirebaseService.shared.deletePortfolioData(databaseTitle: "FiatData", data: allData)
      parentController.parentController.loadAllPortfolios(cryptoPortfolioData: nil, fiatPortfolioData: data)
    }
  }
}
