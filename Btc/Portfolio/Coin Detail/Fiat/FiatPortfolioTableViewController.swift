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
        
        cell.currencyLogo.image = UIImage(named: currency.lowercased())
        
        for (country, symbol, locale, name) in GlobalValues.countryList {
            if symbol == currency {
                cell.currencyName.text = name
            }
        }
        
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FiatPortfolioTableViewController {
    func addPortfolioEntry(portfolioEntry: [String: Any]) {
        
        self.portfolioData.append(portfolioEntry)
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
                                         6: portfolioEntry["time"] as Any,
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
                                     6: portfolioEntry["time"] as Any,
                ])
            
            let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
            defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
        }
    }
}
