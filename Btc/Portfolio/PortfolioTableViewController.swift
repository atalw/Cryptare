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

class PortfolioTableViewController: UITableViewController, PortfolioEntryDelegate {
    
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    var portfolioEntries: [PortfolioEntryModel] = []
    var btcPrice: Double!
    var totalPortfolioValue: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var totalPortfolioLabel: UILabel!
    @IBOutlet weak var totalPercentageLabel: UILabel!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    
    private var portfolioEntryModel: PortfolioEntryModel!
    
    @IBAction func addPortfolioAction(_ sender: Any) {
        showBulletin()
    }
    
    /// The current background style.
    var currentBackground = (name: "Dark", style: BulletinBackgroundViewStyle.dimmed)
    
    lazy var bulletinManager: BulletinManager = {
        
        let rootItem: BulletinItem = BulletinDataSource.makeIntroPage()
        return BulletinManager(rootItem: rootItem)
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        numberFormatter.numberStyle = .currency
        if GlobalValues.currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if GlobalValues.currency == "GBP" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        totalPortfolioLabel.adjustsFontSizeToFitWidth = true
        activityIndicator.startAnimating()
        activityIndicator.addSubview(view)
        getBtcCurrentValue { (success) -> Void in
            if success {
                self.initalizePortfolioEntries()
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
        
        // Register notification observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupDidComplete), name: .SetupDidComplete, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEntered(notification:)), name: .TextFieldEntered, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     * Displays the bulletin.
     */
    
    func showBulletin() {
        bulletinManager.backgroundViewStyle = currentBackground.style
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }

    @objc func setupDidComplete() {
//        BulletinDataSource.userDidCompleteSetup = true
    }
    
    @objc func textFieldEntered(notification: Notification) {
        dateFormatter.dateFormat = "YYYY-MM-dd"

        print("text: \(notification.userInfo?["dateOfPurchase"] as? String) \(notification.userInfo?["amountOfBitcoin"] as? String)")
        
        var amountOfBitcoin = Double(notification.userInfo?["amountOfBitcoin"] as! String)
        var dateOfPurchase = dateFormatter.date(from: notification.userInfo?["dateOfPurchase"] as! String)
        
        addPortfolioEntry(amountOfBitcoin: amountOfBitcoin!, dateOfPurchase: dateOfPurchase!)
        
    }
    
    func addPortfolioEntry(amountOfBitcoin: Double, dateOfPurchase: Date) {
        print(amountOfBitcoin)
        print(dateOfPurchase)
        
        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: amountOfBitcoin, dateOfPurchase: dateOfPurchase, currentBtcPrice: self.btcPrice)

        if dateOfPurchase.daysBetweenDate(toDate: Date()) == 0 {
            print("its equal")
            totalPortfolioValue = totalPortfolioValue + portfolioEntryModel.cost!
            totalAmountOfBitcoin = totalAmountOfBitcoin + portfolioEntryModel.amountOfBitcoin
            // calling this function here is hacky but
            // a completion handler for portfolio initialization function
            // does not work
            setTotalPortfolioValues()
            portfolioEntries.append(portfolioEntryModel)
            tableView.reloadData()
        }
        else {
            portfolioEntryModel.delegate = self
        }
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
        print("\(portfolioEntries.count) countttttt")
        return portfolioEntries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dateFormatter.dateFormat = "dd/MM/YY"

        let portfolio = portfolioEntries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioTableViewCell
        cell.amountOfBitcoinLabel?.text = String(portfolio.amountOfBitcoin)
        cell.amountOfBitcoinLabel.adjustsFontSizeToFitWidth = true
        if let cost = portfolio.cost {
            cell.costLabel?.text = numberFormatter.string(from: NSNumber(value: cost))
            cell.costLabel.adjustsFontSizeToFitWidth = true
        }
        if let date = portfolio.dateOfPurchase {
            cell.dateOfPurchaseLabel?.text = dateFormatter.string(from: date)
            cell.dateOfPurchaseLabel.adjustsFontSizeToFitWidth = true
        }
        if let percentageChange = portfolio.percentageChange {
            cell.percentageChange?.text = "\(percentageChange)%"
        }
        if let currentvalue = portfolio.currentValue {
            cell.currentValueLabel?.text = numberFormatter.string(from: NSNumber(value: currentvalue))
            cell.currentValueLabel.adjustsFontSizeToFitWidth = true
        }
        if let priceChange = portfolio.priceChange {
            cell.priceChangeLabel?.text = numberFormatter.string(from: NSNumber(value: priceChange))
            cell.priceChangeLabel.adjustsFontSizeToFitWidth = true
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
//        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 0.1, dateOfPurchase: self.dateFormatter.date(from: "2017-11-11"), currentBtcPrice: self.btcPrice)
//        portfolioEntryModel.delegate = self

//        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 1.2, dateOfPurchase: self.dateFormatter.date(from: "2016-11-11"), currentBtcPrice: self.btcPrice)
//        portfolioEntryModel.delegate = self
        
        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 0.36886742, dateOfPurchase: self.dateFormatter.date(from: "2017-09-13"), currentBtcPrice: self.btcPrice)
        portfolioEntryModel.delegate = self
        
        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 0.05287515, dateOfPurchase: self.dateFormatter.date(from: "2017-08-12"), currentBtcPrice: self.btcPrice)
        portfolioEntryModel.delegate = self
        
        portfolioEntryModel = PortfolioEntryModel(amountOfBitcoin: 0.02789696, dateOfPurchase: self.dateFormatter.date(from: "2016-10-23"), currentBtcPrice: self.btcPrice)
        portfolioEntryModel.delegate = self
        
    }
    
    func setTotalPortfolioValues() {
        totalPortfolioLabel.text = numberFormatter.string(from: NSNumber(value: totalPortfolioValue))
        let change = (btcPrice*totalAmountOfBitcoin) - totalPortfolioValue
        let percentageChange = (change / totalPortfolioValue) * 100
        let roundedPercentage  = Double(round(100*percentageChange)/100)
        totalPercentageLabel.text = "\(roundedPercentage)%"
        totalPriceChangeLabel.text = numberFormatter.string(from: NSNumber(value: change))
    }
    
}

extension PortfolioTableViewController {
    func didCalculateCostFromDate(data: Double) {
        print(data)
    }
    
    func dataLoaded(portfolioEntry: PortfolioEntryModel) {
        print("dataLoaded")
        totalPortfolioValue = totalPortfolioValue + portfolioEntry.cost!
        totalAmountOfBitcoin = totalAmountOfBitcoin + portfolioEntry.amountOfBitcoin
        // calling this function here is hacky but
        // a completion handler for portfolio initialization function
        // does not work
        setTotalPortfolioValues()
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
