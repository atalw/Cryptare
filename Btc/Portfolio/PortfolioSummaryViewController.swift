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
    let numberFormatter = NumberFormatter()

    let portfolioEntriesConstant = "portfolioEntries"


    var dict: [String: [[String: Any]]] = [:]
    var summary: [String: [String: Double]] = [:]
    var coins: [String] = []
    
    var databaseRef: DatabaseReference!
    var coinRefs: [DatabaseReference] = []

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        numberFormatter.numberStyle = .currency

        tableView.delegate = self
        tableView.dataSource = self
        
        databaseRef = Database.database().reference()
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currency = GlobalValues.currency!
        
        if currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        dict = [:]
        coins = []
        initalizePortfolioEntries()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        databaseRef.removeAllObservers()
        
        for coinRef in coinRefs {
            coinRef.removeAllObservers()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initalizePortfolioEntries() {
        //        defaults.removeObject(forKey: "portfolioEntries")
        
        if let data = defaults.data(forKey: portfolioEntriesConstant) {
            let portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int:Any]]
            dict = [:]
            print(portfolioEntries.count)
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
                    self.tableView.reloadData()

                }
            })
        }

    }
}

extension PortfolioSummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell!.coinCurrentValueLabel.text = numberFormatter.string(from: NSNumber(value: holdingsMarketValue))
        cell!.coinCurrentValueLabel.adjustsFontSizeToFitWidth = true
        
        let holdingsYesterdayValue = summary[coin]!["coinValueYesterday"]! * summary[coin]!["coinAmount"]!
        let priceChange = holdingsMarketValue - holdingsYesterdayValue
        
        let percentageChange = priceChange / holdingsYesterdayValue * 100
        if !percentageChange.isNaN {
            let roundedPercentage = Double(round(percentageChange*100)/100)
            cell!.changePercentageLabel.text = "\(roundedPercentage) %"
            cell!.changeCostLabel.text = numberFormatter.string(from: NSNumber(value: priceChange))
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
