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
import BulletinBoard

class PortfolioTableViewController: UITableViewController {
    
    var coin: String!
    
    // MARK: - Constants
    
    let defaults = UserDefaults.standard
    
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    let portfolioEntriesConstant = "portfolioEntries"
    let portfolioCellConstant = "portfolioCell"
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    // MARK: - Variable initalization
    
    var parentController: PortfolioViewController!
    var portfolioData: [[String: Any]] = []
    var portfolioEntries: [PortfolioEntryModel] = []
    var btcPrice: Double!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - Bulletin variables
    
    /// The current background style.
    var currentBackground = (name: "Dark", style: BulletinBackgroundViewStyle.dimmed)
    
    lazy var bulletinManager: BulletinManager = {
        
        let rootItem: BulletinItem = BulletinDataSource.makeTextFieldPage(coin: self.coin)
        return BulletinManager(rootItem: rootItem)
        
    }()

    
    // MARK: - UI Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets.zero
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        numberFormatter.numberStyle = .currency
        if GlobalValues.currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if GlobalValues.currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        activityIndicator.addSubview(view)
        self.activityIndicator.hidesWhenStopped = true
        
        print(portfolioData)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Register notification observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupDidComplete), name: .SetupDidComplete, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEntered(notification:)), name: .TextFieldEntered, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        getBtcCurrentValue { (success) -> Void in
            if success {
                self.initalizePortfolioEntries()
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        else  {
            cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSellCell", for: indexPath) as! PortfolioTableViewCell
        }
        
        
        cell.amountOfBitcoinLabel.text = String(portfolio.coinAmount)
        cell.amountOfBitcoinLabel.adjustsFontSizeToFitWidth = true
        if portfolio.type == "buy" {
            cell.amountOfBitcoinLabel.textColor = greenColour
        }
        else if portfolio.type == "sell" {
            cell.amountOfBitcoinLabel.textColor = redColour
        }
        
        if let cost = portfolio.cost {
            cell.costLabel?.text = numberFormatter.string(from: NSNumber(value: cost))
            cell.costLabel?.adjustsFontSizeToFitWidth = true
        }
        
        if let date = portfolio.dateOfPurchase {
            cell.dateOfPurchaseLabel?.text = dateFormatter.string(from: date)
            cell.dateOfPurchaseLabel?.adjustsFontSizeToFitWidth = true
        }
        
        if let percentageChange = portfolio.percentageChange {
            cell.percentageChange?.text = "\(percentageChange)%"
            cell.percentageChange?.adjustsFontSizeToFitWidth = true
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
        
        if let currentvalue = portfolio.currentValue {
            cell.currentValueLabel?.text = numberFormatter.string(from: NSNumber(value: currentvalue))
            cell.currentValueLabel?.adjustsFontSizeToFitWidth = true
        }
        
        if let priceChange = portfolio.priceChange {
            cell.priceChangeLabel?.text = numberFormatter.string(from: NSNumber(value: priceChange))
            cell.priceChangeLabel?.adjustsFontSizeToFitWidth = true
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
        print("empty")
        let messageLabel = UILabel()
        messageLabel.text = "Add a transaction"
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
        tableView.backgroundView?.backgroundColor = UIColor.groupTableViewBackground
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
    
    // MARK: - Portfolio functions

    func initalizePortfolioEntries() {
        if portfolioData.count == 0 {
            tableEmptyMessage()
        }
        else {
            for portfolio in portfolioData {
                PortfolioEntryModel(coin: coin, type: portfolio["type"] as! String, coinAmount: portfolio["coinAmount"] as! Double, dateOfPurchase: portfolio["date"] as! Date, cost: portfolio["cost"] as! Double, currentCoinPrice: self.btcPrice, delegate: self)
            }
        }
    }
    
    @objc func textFieldEntered(notification: Notification) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let type = notification.userInfo?["type"] as! String
        let amountOfBitcoin = Double(notification.userInfo?["coinAmount"] as! String)
        let dateOfPurchase = dateFormatter.date(from: notification.userInfo?["date"] as! String)
        let cost = Double(notification.userInfo?["cost"] as! String)
        if amountOfBitcoin != nil && dateOfPurchase != nil && cost != nil {
            addPortfolioEntry(type: type, amountOfBitcoin: amountOfBitcoin!, dateOfPurchase: dateOfPurchase!, cost: cost!)
        }
    }
    
    func addPortfolioEntry(type: String, amountOfBitcoin: Double, dateOfPurchase: Date, cost: Double) {
        tableView.backgroundView = nil
        PortfolioEntryModel(coin: coin, type: type, coinAmount: amountOfBitcoin, dateOfPurchase: dateOfPurchase, cost: cost, currentCoinPrice: self.btcPrice, delegate: self)
        savePortfolioEntry(type: type, amountOfBitcoin: amountOfBitcoin, dateOfPurchase: dateOfPurchase, cost: cost)
    }
    
    // append portfolio entry to userdefaults stored portfolios, else create new data entry
    func savePortfolioEntry(type: String, amountOfBitcoin: Double, dateOfPurchase: Date, cost: Double) {
        let dateString = dateFormatter.string(from: dateOfPurchase)

        if var data = defaults.data(forKey: portfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                portfolioEntries.append([0: coin as Any, 1: type as Any, 2: amountOfBitcoin as Any, 3: dateString as Any, 4: cost as Any])
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: portfolioEntriesConstant)
            }
        }
        else {
            var portfolioEntries: [[Int:Any]] = []
            portfolioEntries.append([0: coin as Any, 1: type as Any, 2: amountOfBitcoin as Any, 3: dateString as Any, 4: cost as Any])
            let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
            defaults.set(newData, forKey: portfolioEntriesConstant)
        }
    }
    
    func deletePortfolioEntry(portfolioEntry: PortfolioEntryModel) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if var data = defaults.data(forKey: portfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                let dateString = dateFormatter.string(from: portfolioEntry.dateOfPurchase)
                for index in 0..<portfolioEntries.count {
                    if let coin = portfolioEntries[index][0] as? String, let type = portfolioEntries[index][1] as? String, let amountOfBitcoin = portfolioEntries[index][2] as? Double, let date = portfolioEntries[index][3] as? String {
                        if coin == portfolioEntry.coin && type == portfolioEntry.type && amountOfBitcoin == portfolioEntry.coinAmount && dateString == date {
                            portfolioEntries.remove(at: index)
                            if type == "buy" {
                                parentController.subtractTotalPortfolioValues(amountOfBitcoin: amountOfBitcoin, cost: portfolioEntry.cost, currentValue: portfolioEntry.currentValue)
                            }
                            else {
                                parentController.subtractSellTotalPortfolioValues(amountOfBitcoin: amountOfBitcoin, cost: portfolioEntry.cost, currentValue: portfolioEntry.currentValue)
                            }
                            break
                        }
                    }
                }
                if portfolioEntries.count == 0 {
                    tableEmptyMessage()
                }
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: portfolioEntriesConstant)
            }
        }
    }
    
//    func valueToData(_ value: [String: (Double, String)]) -> Data {
//        var converted = value.mapValues { (value) -> [Int:Any] in
//            return [0: value.0, 1: value.1]
//        }
//        return NSKeyedArchiver.archivedData(withRootObject: converted)
//    }
    
    /**
     * Displays the bulletin.
     */
    
    func showAddBuyBulletin() {
        bulletinManager = {
            let rootItem: BulletinItem = BulletinDataSource.makeTextFieldPage(coin: self.coin)
            return BulletinManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
    
    func showAddSellBulletin() {
        bulletinManager = {
            let rootItem: BulletinItem = BulletinDataSource.makeSellPortfolioPage()
            return BulletinManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
    
    @objc func setupDidComplete() {
        //        BulletinDataSource.userDidCompleteSetup = true
    }

    func getBtcCurrentValue(completion: @escaping (_ success: Bool) -> Void) {
        Alamofire.request("https://api.coindesk.com/v1/bpi/currentprice/\(GlobalValues.currency!).json").responseJSON(completionHandler: { response in
            let json = JSON(data: response.data!)
            if let price = json["bpi"][GlobalValues.currency!]["rate_float"].double {
                self.btcPrice = price
                completion(true)
            }
        })
    }
    
}

extension PortfolioTableViewController {
    
}

extension PortfolioTableViewController: PortfolioEntryDelegate {
    
    func dataLoaded(portfolioEntry: PortfolioEntryModel) {
        if portfolioEntry.type == "buy" {
            parentController.addTotalPortfolioValues(amountOfBitcoin: portfolioEntry.coinAmount, cost: portfolioEntry.cost, currentValue: portfolioEntry.currentValue)
        }
        else if portfolioEntry.type == "sell" {
            parentController.addSellTotalPortfolioValues(amountOfBitcoin: portfolioEntry.coinAmount, cost: portfolioEntry.cost, currentValue: portfolioEntry.currentValue)
        }
        portfolioEntries.append(portfolioEntry)
        tableView.reloadData()
    }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}
