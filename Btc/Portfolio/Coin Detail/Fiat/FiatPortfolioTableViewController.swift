//
//  FiatPortfolioTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class FiatPortfolioTableViewController: UITableViewController {
    
    var parentController: FiatPortfolioViewController!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    
    var currency: String!
    
    var portfolioData: [[String: Any]] = []
    
    var portfolioEntries: [FiatTransactionEntryModel] = []
    
    let fiatPortfolioEntriesConstant = "fiatPortfolioEntries"


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
        
        if entry.transactionType == "deposit" {
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
                                                      transactionType: portfolio["type"] as! String,
                                                      exchange: portfolio["exchange"] as! String,
                                                      amount: portfolio["amount"] as! Double,
                                                      fees: portfolio["fees"] as! Double,
                                                      date: portfolio["date"] as! Date,
                                                      time: portfolio["time"] as! Date)
                portfolioEntries.append(entry)
                
                if entry.transactionType == "deposit" {
                    parentController.addToTotalDeposited(value: (entry.amount-entry.fees))
                }
                else if entry.transactionType == "withdraw" {
                    parentController.addToTotalWithdrawn(value: (entry.amount+entry.fees))
                }
            }
        }
        
        tableView.reloadData()

    }
    
    // append portfolio entry to userdefaults stored portfolios, else create new data entry
    func savePortfolioEntry(portfolioEntry: [String: Any]) {
        //        let dateString = dateFormatter.string(from: date)
//        let timeString = timeFormatter.string(from: portfolioEntry["time"] as! Date)
        
        if var data = defaults.data(forKey: fiatPortfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                portfolioEntries.append([0: currency as Any,
                                         1: portfolioEntry["type"] as Any,
                                         2: portfolioEntry["exchange"] as Any,
                                         3: portfolioEntry["amount"] as Any,
                                         4: portfolioEntry["fees"] as Any,
                                         5: portfolioEntry["date"] as Any,
                                         6: portfolioEntry["time"] as Any
                    ])
                
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
            }
        }
        else {
            var portfolioEntries: [[Int:Any]] = []
            
            portfolioEntries.append([0: currency as Any,
                                     1: portfolioEntry["type"] as Any,
                                     2: portfolioEntry["exchange"] as Any,
                                     3: portfolioEntry["amount"] as Any,
                                     4: portfolioEntry["fees"] as Any,
                                     5: portfolioEntry["date"] as Any,
                                     6: portfolioEntry["time"] as Any
                ])
            
            let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
            defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
        }
    }
    
    func deletePortfolioEntry(portfolioEntry: FiatTransactionEntryModel) {
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        timeFormatter.dateFormat = "hh:mm a"
        
        if var data = defaults.data(forKey: fiatPortfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                
                
                for index in 0..<portfolioEntries.count {
                    
                    let currency = portfolioEntries[index][0] as? String
                    let type = portfolioEntries[index][1] as? String
                    let exchange = portfolioEntries[index][2] as? String
                    let amount = portfolioEntries[index][3] as? Double
                    let fees = portfolioEntries[index][4] as! Double
                    let date = portfolioEntries[index][5] as? Date
                    let time = portfolioEntries[index][6] as? Date

                    if currency == portfolioEntry.currency &&
                        type == portfolioEntry.transactionType &&
                        exchange == portfolioEntry.exchange &&
                        amount == portfolioEntry.amount &&
                        fees == portfolioEntry.fees &&
                        date == portfolioEntry.date &&
                        time == portfolioEntry.time {
                        
                        if type == "deposit" {
                            parentController.removeDepositedEntry(value: amount!)
                        }
                        else if type == "withdraw" {
                            parentController.removeWithdrawnEntry(value: amount!)
                        }
                        
                        portfolioEntries.remove(at: index)
                        
                        break
                    }
                }
                if portfolioEntries.count == 0 {
//                    tableEmptyMessage()
                }
                
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
            }
        }
    }
}
