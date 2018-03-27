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
    
    var currency: String!
    
    var portfolioData: [[String: Any]] = []
    var portfolioName: String!
    
    var portfolioEntries: [FiatTransactionEntryModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        portfolioEntries.removeAll()
        
//        activityIndicator.startAnimating()
        self.initalizePortfolioEntries()

    }
    
    override func viewWillLayoutSubviews() {
        if portfolioEntries.count > 0 {
            parentController.containerViewHeight.constant = tableView.contentSize.height
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return portfolioEntries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        dateFormatter.dateFormat = "dd MMM, YYYY"
        
        let entry = portfolioEntries[indexPath.row]
        var cell: FiatPortfolioTableViewCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! FiatPortfolioTableViewCell
        
       
        
        cell.amountLabel.text = entry.amount.asCurrency
        cell.feesLabel.text = entry.fees.asCurrency
        cell.dateLabel.text = dateFormatter.string(from: entry.date)
//        cell.timeLabel.text = entry.time
        
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
//            self.parentController.setTotalPortfolioValues()
        }
        
        return [delete]
    }
    
}

extension FiatPortfolioTableViewController {
    func addPortfolioEntry(portfolioEntry: [String: Any]) {
        
        self.portfolioData.append(portfolioEntry)
        
        if portfolioEntry["type"] as! String == "deposit" {
            parentController.addToTotalDeposited(value: portfolioEntry["amount"] as! Double)
        }
        else if portfolioEntry["type"] as! String == "withdraw" {
            parentController.addToTotalWithdrawn(value: portfolioEntry["amount"] as! Double)
        }
        tableView.reloadData()
        savePortfolioEntry(portfolioEntry: portfolioEntry)
    }
    
    func initalizePortfolioEntries() {
        if portfolioData.count == 0 {
//            tableEmptyMessage()
        }
        else {
            for portfolio in portfolioData {
                let entry = FiatTransactionEntryModel(currency: currency,
                                                      type: portfolio["type"] as! String,
                                                      exchange: portfolio["exchange"] as! String,
                                                      amount: portfolio["amount"] as! Double,
                                                      fees: portfolio["fees"] as! Double,
                                                      date: portfolio["date"] as! Date)
                portfolioEntries.append(entry)
                
                if entry.type == "deposit" {
                    parentController.addToTotalDeposited(value: (entry.amount-entry.fees))
                }
                else if entry.type == "withdraw" {
                    parentController.addToTotalWithdrawn(value: (entry.amount+entry.fees))
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
        print(allData)
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
            print(allData)
            parentController.parentController.loadAllPortfolios(cryptoPortfolioData: nil, fiatPortfolioData: data)
        }
    }
    
    func deletePortfolioEntry(portfolioEntry: FiatTransactionEntryModel) {
        
        var allData = Defaults[.fiatPortfolioData]
        if var currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
            var data: [String: [[String: Any]] ] = [:]
            for (currency, transactions) in currentPortfolioData {
                // copy all transactions to new dict
                data[currency] = transactions
                if currency == portfolioEntry.currency {
                    for (index, transaction) in data[currency]!.enumerated() {
                    
                        let type = transaction["type"] as? String
                        let exchange = transaction["exchange"] as? String
                        let amount = transaction["amount"] as! Double
                        let fees = transaction["fees"] as? Double
                        let date = transaction["date"] as? Date
                        
                        if portfolioEntry.type == type &&
                            portfolioEntry.exchange == exchange &&
                            portfolioEntry.amount == amount &&
                            portfolioEntry.fees == fees &&
                            portfolioEntry.date == date {
                            
                            if type == "deposit" {
                                parentController.removeDepositedEntry(value: amount)
                            }
                            else if type == "withdraw" {
                                parentController.removeWithdrawnEntry(value: amount)
                            }
                            data[currency]!.remove(at: index)
                            break
                        }
                    }
                }
            }
            
            if portfolioEntries.count == 0 {
//                tableEmptyMessage()
            }
            
            allData[portfolioName] = data
            Defaults[.fiatPortfolioData] = allData
            parentController.parentController.loadAllPortfolios(cryptoPortfolioData: nil, fiatPortfolioData: data)
        }
    }
}
