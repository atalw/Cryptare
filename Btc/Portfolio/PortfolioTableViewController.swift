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

class PortfolioTableViewController: UITableViewController, PortfolioEntryDelegate {
    
    
    let dateFormatter = DateFormatter()
    var portfolioEntries: [PortfolioEntryModel] = []
    var btcPrice: Double!
    
    private var portfolioEntryModel: PortfolioEntryModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        

        getBtcCurrentValue { (success) -> Void in
            if success {
                self.initalizePortfolioEntries()
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let portfolio = portfolioEntries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioTableViewCell
        cell.amountOfBitcoinLabel?.text = String(portfolio.amountOfBitcoin)
        if let cost = portfolio.cost {
            cell.costLabel?.text = String(cost)
        }
        if let date = portfolio.dateOfPurchase {
            cell.dateOfPurchaseLabel?.text = String(describing: date)
        }
        if let percentageChange = portfolio.percentageChange {
            cell.percentageChange?.text = String(percentageChange)
        }
        if let currentvalue = portfolio.currentValue {
            cell.currentValueLabel?.text = String(currentvalue)
        }
        if let priceChange = portfolio.priceChange {
            cell.priceChangeLabel?.text = String(priceChange)
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

    func getBtcCurrentValue(completion: @escaping (_ success: Bool) -> Void) {
        Alamofire.request("https://api.coindesk.com/v1/bpi/currentprice/\(GlobalValues.currency!).json").responseJSON(completionHandler: { response in
            let json = JSON(data: response.data!)
            if let price = json["bpi"][GlobalValues.currency!]["rate_float"].double {
                self.btcPrice = price
                completion(true)
            }
        })
    }
    
    func initalizePortfolioEntries() {
        self.portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 0.1, dateOfPurchase: self.dateFormatter.date(from: "2017-11-11"), currentBtcPrice: self.btcPrice)
        self.portfolioEntryModel.delegate = self
        
        self.portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 1.2, dateOfPurchase: self.dateFormatter.date(from: "2016-11-11"), currentBtcPrice: self.btcPrice)
        self.portfolioEntryModel.delegate = self
    }
}

extension PortfolioTableViewController {
    func didCalculateCostFromDate(data: Double) {
        print(data)
    }
    
    func dataLoaded(portfolio: PortfolioEntryModel) {
        print("dataLoaded")
        self.portfolioEntries.append(portfolio)
        self.tableView.reloadData()
    }
}
