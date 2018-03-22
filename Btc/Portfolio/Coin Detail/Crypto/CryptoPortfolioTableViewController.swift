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

class CryptoPortfolioTableViewController: UITableViewController {
    
    var coin: String!
    var coinPrice: Double!
    // MARK: - Constants
    
    let defaults = UserDefaults.standard
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let portfolioEntriesConstant = "portfolioEntries"
    let portfolioCellConstant = "portfolioBuyCell"
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    // MARK: - Variable initalization
    
    var parentController: CryptoPortfolioViewController!
    var portfolioData: [[String: Any]] = []
    var portfolioEntries: [PortfolioEntryModel] = []
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - Bulletin variables
    
    /// The current background style.
    var currentBackground = (name: "Dark", style: BulletinBackgroundViewStyle.dimmed)
    
    // MARK: - UI Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "hh:mm a"

        activityIndicator.addSubview(view)
        self.activityIndicator.hidesWhenStopped = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Register notification observers
//        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEntered(notification:)), name: .TextFieldEntered, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        portfolioEntries.removeAll()

        activityIndicator.startAnimating()
        self.initalizePortfolioEntries()
        self.activityIndicator.stopAnimating()
        
       
    }
    
    
    
    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        tableView.reloadData()
        if portfolioEntries.count > 0 {
            parentController.containerViewHeightConstraint.constant = tableView.contentSize.height
//            tableView.reloadData()
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
        
        print(tableView.contentSize.height)
        
        let portfolio = portfolioEntries[indexPath.row]
        var cell: PortfolioTableViewCell
        if portfolio.type == "buy" {
            cell = tableView.dequeueReusableCell(withIdentifier: portfolioCellConstant, for: indexPath) as! PortfolioTableViewCell
        }
        else  {
            cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSellCell", for: indexPath) as! PortfolioTableViewCell
        }
        
        for (symbol, name) in GlobalValues.coins {
            if symbol == coin {
//                cell.coinNameLabel.text = name
                if symbol == "IOT" {
                    cell.coinLogoImage.image = UIImage(named: "miota")
                }
                else {
                    cell.coinLogoImage.image = UIImage(named: symbol.lowercased())
                }
            }
        }
        
//        cell.coinNameLabel.adjustsFontSizeToFitWidth = true
        
        cell.amountOfCoinsLabel.text = String(portfolio.amountOfCoins)
        cell.amountOfCoinsLabel.adjustsFontSizeToFitWidth = true
        if portfolio.type == "buy" {
            cell.amountOfCoinsLabel.textColor = greenColour
            if let date = portfolio.date, let time = portfolio.time {
                dateFormatter.dateFormat = "dd MMM, YYYY"
                let dateString = dateFormatter.string(from: date)
                let timeString = timeFormatter.string(from: time)
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
            if let date = portfolio.date, let time = portfolio.time {
                dateFormatter.dateFormat = "dd MMM, YYYY"
                let dateString = dateFormatter.string(from: date)
                let timeString = timeFormatter.string(from: time)
                if let exchange = portfolio.exchange {
                    cell.transactionInfoLabel.text = "Sold on \(dateString) via \(exchange) at \(timeString)"

                }
                else {
                    cell.transactionInfoLabel.text = "Sold on \(dateString) at \(timeString)"
                }
            }
        }
        
        if let cost = portfolio.costPerCoin, let amountOfCoins = portfolio.amountOfCoins, let fees = portfolio.fees {
            cell.costPerCoinLabel.adjustsFontSizeToFitWidth = true
            cell.feesLabel?.adjustsFontSizeToFitWidth = true
            
            let total = (cost * amountOfCoins) - fees
            
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
        
//        if let date = portfolio.dateOfPurchase {
//            cell.dateOfPurchaseLabel?.text = dateFormatter.string(from: date)
//            cell.dateOfPurchaseLabel?.adjustsFontSizeToFitWidth = true
//        }
        
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
            cell.currentValueLabel?.text = currentvalue.asCurrency
            cell.currentValueLabel?.adjustsFontSizeToFitWidth = true
        }
        
//        if let priceChange = portfolio.priceChange {
//            cell.priceChangeLabel?.text = priceChange.asCurrency
//            cell.priceChangeLabel?.adjustsFontSizeToFitWidth = true
//        }
        
        if let fees = portfolio.fees {
            
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
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
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
        let bulletinManager = { () -> BulletinManager in
            let rootItem: BulletinItem = BulletinDataSource.makeTextFieldPage(coin: self.coin)
            return BulletinManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
    
    func showAddSellBulletin() {
        let bulletinManager = { () -> BulletinManager in
            let rootItem: BulletinItem = BulletinDataSource.makeSellPortfolioPage(coin: self.coin)
            return BulletinManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
    
    @objc func setupDidComplete() {
        //        BulletinDataSource.userDidCompleteSetup = true
    }

    func getCoinMarketValue(coin: String, completion: @escaping (_ success: Bool) -> Void) {
//       let url = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=\(coin)&tsyms=\(GlobalValues.currency!)")!
//
//        Alamofire.request(url).responseJSON(completionHandler: { response in
//
//            let json = JSON(data: response.data!)
//            print(json)
//            if let price = json[GlobalValues.currency!].double {
//                self.coinPrice = price
//                completion(true)
//            }
//        })
        
    }
    
}

extension CryptoPortfolioTableViewController {
    // MARK: - Portfolio functions
    
    func addPortfolioEntry(portfolioEntry: [String: Any]) {
        
        self.portfolioData.append(portfolioEntry)
        
        savePortfolioEntry(portfolioEntry: portfolioEntry)
    }
    
    func initalizePortfolioEntries() {
        if portfolioData.count == 0 {
            tableEmptyMessage()
        }
        else {
            for portfolio in portfolioData {
                PortfolioEntryModel(type: portfolio["type"] as! String,
                                    coin: portfolio["coin"] as! String,
                                    tradingPair: portfolio["tradingPair"] as! String,
                                    exchange: portfolio["exchange"] as! String,
                                    costPerCoin: portfolio["costPerCoin"] as! Double,
                                    amountOfCoins: portfolio["amountOfCoins"] as! Double,
                                    fees: portfolio["fees"] as! Double,
                                    date: portfolio["date"] as! Date,
                                    time: portfolio["time"] as! Date,
                                    currentCoinPrice: self.coinPrice,
                                    delegate: self)
            }
        }
    }
    
    // append portfolio entry to userdefaults stored portfolios, else create new data entry
    func savePortfolioEntry(portfolioEntry: [String: Any]) {
        //        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: portfolioEntry["time"] as! Date)
        
        if var data = defaults.data(forKey: portfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                portfolioEntries.append([0: portfolioEntry["type"] as Any,
                                         1: portfolioEntry["coin"] as Any,
                                         2: portfolioEntry["tradingPair"] as Any,
                                         3: portfolioEntry["exchange"] as Any,
                                         4: portfolioEntry["costPerCoin"] as Any,
                                         5: portfolioEntry["amountOfCoins"] as Any,
                                         6: portfolioEntry["fees"] as Any,
                                         7: portfolioEntry["date"] as Any,
                                         8: timeString as Any
                    ])
                
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: portfolioEntriesConstant)
                parentController.parentController.loadAllPortfolios()
            }
        }
        else {
            var portfolioEntries: [[Int:Any]] = []
            
            portfolioEntries.append([0: portfolioEntry["type"] as Any,
                                     1: portfolioEntry["coin"] as Any,
                                     2: portfolioEntry["tradingPair"] as Any,
                                     3: portfolioEntry["exchange"] as Any,
                                     4: portfolioEntry["costPerCoin"] as Any,
                                     5: portfolioEntry["amountOfCoins"] as Any,
                                     6: portfolioEntry["fees"] as Any,
                                     7: portfolioEntry["date"] as Any,
                                     8: timeString as Any
                ])
            
            let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
            defaults.set(newData, forKey: portfolioEntriesConstant)
            parentController.parentController.loadAllPortfolios()
        }
    }
    
    
    func deletePortfolioEntry(portfolioEntry: PortfolioEntryModel) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "hh:mm a"
        
        if var data = defaults.data(forKey: portfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                
//                let dateString = dateFormatter.string(from: portfolioEntry.date)
                let timeString = timeFormatter.string(from: portfolioEntry.time)
                
                for index in 0..<portfolioEntries.count {
                    
                    let type = portfolioEntries[index][0] as? String
                    let coin = portfolioEntries[index][1] as? String
                    let tradingPair = portfolioEntries[index][2] as? String
                    let exchange = portfolioEntries[index][3] as? String
                    let costPerCoin = portfolioEntries[index][4] as! Double
                    let amountOfCoins = portfolioEntries[index][5] as? Double
                    let fees = portfolioEntries[index][6] as? Double
                    let date = portfolioEntries[index][7] as? Date
                    let time = portfolioEntries[index][8] as? String

                    if type == portfolioEntry.type && coin == portfolioEntry.coin &&
                        amountOfCoins == portfolioEntry.amountOfCoins &&
                        portfolioEntry.date == date && costPerCoin == portfolioEntry.costPerCoin &&
                        timeString == time && exchange == portfolioEntry.exchange {
                        
                        if type == "buy" {
                            parentController.subtractTotalPortfolioValues(amountOfBitcoin: amountOfCoins!, cost: portfolioEntry.costPerCoin, currentValue: portfolioEntry.currentValue)
                        }
                        else {
                            parentController.subtractSellTotalPortfolioValues(amountOfBitcoin: amountOfCoins!, cost: portfolioEntry.costPerCoin, currentValue: portfolioEntry.currentValue)
                        }
                        
                        portfolioEntries.remove(at: index)
                        break
                    }
                }
                if portfolioEntries.count == 0 {
                    tableEmptyMessage()
                }
                
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: portfolioEntriesConstant)
                parentController.parentController.loadAllPortfolios()
            }
        }
    }
}

extension CryptoPortfolioTableViewController: PortfolioEntryDelegate {
    
    func dataLoaded(portfolioEntry: PortfolioEntryModel) {
        if portfolioEntry.type == "buy" {
            parentController.addTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.totalCost, currentValue: portfolioEntry.currentValue)
        }
        else if portfolioEntry.type == "sell" {
            parentController.addSellTotalPortfolioValues(amountOfBitcoin: portfolioEntry.amountOfCoins, cost: portfolioEntry.totalCost, currentValue: portfolioEntry.currentValue)
        }
        portfolioEntries.append(portfolioEntry)
        
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
