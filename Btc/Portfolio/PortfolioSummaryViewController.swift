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

class PortfolioSummaryViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")

    let portfolioEntriesConstant = "portfolioEntries"

    var dict: [String: [[String: Any]]] = [:]
    var summary: [String: [String: Double]] = [:]
    var yesterdayCoinValues: [String: Double] = [:]
    var coins: [String] = []
    
    var databaseRef: DatabaseReference!
    var coinRefs: [DatabaseReference] = []
    
    @IBOutlet weak var option24hrButton: UIButton!
    @IBOutlet weak var optionAllTimeButton: UIButton!
    
    @IBOutlet weak var currentPortfolioValueLabel: UILabel!
    @IBOutlet weak var totalInvestedLabel: UILabel!
    @IBOutlet weak var totalPercentageChangeLabel: UILabel!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateOldFormatPortfolioEntries()
        
        yesterdayCoinValues = [:]
        
        option24hrButton.isSelected = true
        optionAllTimeButton.isSelected = false
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseRef = Database.database().reference()
        dict = [:]
        coins = []
        initalizePortfolioEntries()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateOldFormatPortfolioEntries() {
        if let data = defaults.data(forKey: portfolioEntriesConstant) {
            var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int:Any]]
            dict = [:]
            print(portfolioEntries.count)
            for index in 0..<portfolioEntries.count {
                let firstElement = portfolioEntries[index][0] as? String
                let secondElement = portfolioEntries[index][1] as? Double
                let thirdElement = portfolioEntries[index][2] as? String

                let coin = "BTC"
                if let type = firstElement, let coinAmount = secondElement, let date = thirdElement {
                    calculateCostFromDate(dateString: date) { value in
                        let price = coinAmount * value
                        portfolioEntries.remove(at: index)
                        let data = [0: coin as Any, 1: type as Any, 2: coinAmount as Any, 3: date as Any, 4: price as Any]
                        portfolioEntries.insert(data, at: index)
                        let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                        self.defaults.set(newData, forKey: "portfolioEntries")
                    }
                    
                }
            }
        }
    }
        
    func calculateCostFromDate(dateString: String, completionHandler: @escaping (Double) -> ()) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.date(from: dateString)
        let unixTime = Int((date?.timeIntervalSince1970)!)
        let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=BTC&tsyms=\(GlobalValues.currency!)&ts=\(unixTime)")!
        Alamofire.request(url).responseJSON(completionHandler: { response in
            
            let json = JSON(data: response.data!)
            if let price = json["BTC"][GlobalValues.currency!].double {
                completionHandler(price)
            }
        })
    }
    
    func initalizePortfolioEntries() {
        //        defaults.removeObject(forKey: "portfolioEntries")
        
        if let data = defaults.data(forKey: portfolioEntriesConstant) {
            let portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int:Any]]
            dict = [:]
            print(portfolioEntries.count)
            print(portfolioEntries)
            for index in 0..<portfolioEntries.count {
                let firstElement = portfolioEntries[index][0] as? String
                let secondElement = portfolioEntries[index][1] as? String
                let thirdElement = portfolioEntries[index][2] as? Double
                let fourthElement = portfolioEntries[index][3] as? String
                let fifthElement = portfolioEntries[index][4] as? Double
                
                if let coin = firstElement, let type = secondElement, let coinAmount = thirdElement, let date = dateFormatter.date(from: fourthElement as! String), let cost = fifthElement {
                    if dict[coin] == nil {
                        dict[coin] = []
                    }
                    dict[coin]!.append(["type": type, "coinAmount": coinAmount, "date": date, "cost": cost])
                }
            }
        }
        
        for coin in dict.keys {
            coins.append(coin)
        }
        calculatePortfolioSummary()
//        tableView.reloadData()
    }
    
    func calculatePortfolioSummary() {
        for coin in dict.keys {
            summary[coin] = [:]
            summary[coin]!["coinAmount"] = 0.0
            summary[coin]!["cost"] = 0.0
            summary[coin]!["coinMarketValue"] = 0.0 // market value of 1 coin
            summary[coin]!["holdingsMarketValue"] = 0.0 // market value of holdings
            summary[coin]!["coinValueYesterday"] = 0.0
            summary[coin]!["holdingsValueYesterday"] = 0.0
            
            for entry in dict[coin]! {
                if entry["type"] as! String == "buy" {
                    summary[coin]!["coinAmount"] = summary[coin]!["coinAmount"]! + (entry["coinAmount"] as! Double)
                    summary[coin]!["cost"] = summary[coin]!["cost"]! + (entry["cost"] as! Double)
                }
                else if entry["type"] as! String == "sell" {
                    summary[coin]!["coinAmount"] = summary[coin]!["coinAmount"]! - (entry["coinAmount"] as! Double)
                    summary[coin]!["cost"] = summary[coin]!["cost"]! - (entry["cost"] as! Double)
                }
            }
            
            coinRefs.append(databaseRef.child(coin))
            let index = coinRefs.count - 1
            
            coinRefs[index].observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    print(self.summary[coin]!["coinAmount"]!)
                    self.summary[coin]!["coinMarketValue"] = dict[GlobalValues.currency!]!["price"] as! Double
                    self.summary[coin]!["holdingsMarketValue"] = self.summary[coin]!["coinAmount"]! * self.summary[coin]!["coinMarketValue"]!
                    self.updateSummaryLabels()
                    self.tableView.reloadData()
                }
            })
        }
        getCoinValueYesterday()
    }
    
    func getCoinValueYesterday() {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let yesterday = Int(Date().timeIntervalSince1970 - (24*60*60))
        for coin in coins {
            let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=\(coin)&tsyms=\(GlobalValues.currency!)&ts=\(yesterday)")!
            
            Alamofire.request(url).responseJSON(completionHandler: { response in
                
                let json = JSON(data: response.data!)
                print(json)
                if let price = json[coin][GlobalValues.currency!].double {
                    self.summary[coin]!["coinValueYesterday"] = price
                    self.summary[coin]!["holdingsValueYesterday"] = price * self.summary[coin]!["coinAmount"]!
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func updateSummaryLabels() {
        var currentPortfolioValue = 0.0
        var totalInvested = 0.0
        var yesterdayPortfolioValue = 0.0
        for coin in coins {
            currentPortfolioValue = currentPortfolioValue + summary[coin]!["holdingsMarketValue"]!
            totalInvested = totalInvested + summary[coin]!["cost"]!
            yesterdayPortfolioValue = yesterdayPortfolioValue + summary[coin]!["holdingsValueYesterday"]!
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
    
    
}

extension PortfolioSummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateSummaryLabels()
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSummaryCell") as? PortfolioSummaryTableViewCell
        
        let coin = coins[indexPath.row]
        
        cell!.coinSymbolLabel.text = "\(coin)"
        cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
        
        cell!.coinImage.image = UIImage(named: coin.lowercased())
        for (symbol, name) in GlobalValues.coins {
            if symbol == coin {
                cell!.coinNameLabel.text = name
            }
        }
        
        cell!.coinHoldingsLabel.text = "\(summary[coin]!["coinAmount"]!) \(coin)"
        cell!.coinHoldingsLabel.adjustsFontSizeToFitWidth = true
        
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
            let coinCost = summary[coin]!["cost"]!
            priceChange = holdingsMarketValue - coinCost
            
            percentageChange = priceChange / coinCost * 100
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
        
        cell!.changePercentageLabel.adjustsFontSizeToFitWidth = true
        cell!.changeCostLabel.adjustsFontSizeToFitWidth = true
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! PortfolioViewController
        
        targetViewController.coin = coins[indexPath.row]
        targetViewController.portfolioData = dict[coins[indexPath.row]]!
        
        self.navigationController?.pushViewController(targetViewController, animated: true)

    }
}
