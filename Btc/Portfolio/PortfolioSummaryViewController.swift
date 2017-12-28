//
//  PortfolioSummaryViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioSummaryViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()

    let portfolioEntriesConstant = "portfolioEntries"


    var dict: [String: [[String: Any]]] = [:]
    var summary: [String: [String: Any]] = [:]
    var coins: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dict = [:]
        coins = []
        initalizePortfolioEntries()
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
        tableView.reloadData()
    }
    
    func calculatePortfolioSummary() {
        for coin in dict.keys {
            summary[coin] = [:]
            summary[coin]!["coinAmount"] = 0.0
            summary[coin]!["cost"] = 0.0
            for entry in dict[coin]! {
                summary[coin]!["coinAmount"] = (summary[coin]!["coinAmount"] as! Double) + (entry["coinAmount"] as! Double)
                summary[coin]!["cost"] = (summary[coin]!["cost"] as! Double) + (entry["cost"] as! Double)
            }
        }
        print(summary)
    }
}

extension PortfolioSummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSummaryCell") as? PortfolioSummaryTableViewCell
        
        cell!.coinSymbolLabel.text = "\(coins[indexPath.row])"
        cell!.coinImage.image = UIImage(named: coins[indexPath.row].lowercased())
        for (symbol, name) in GlobalValues.coins {
            if symbol == coins[indexPath.row] {
                cell!.coinNameLabel.text = name
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! PortfolioViewController
        
        targetViewController.coin = coins[indexPath.row]
        targetViewController.portfolioData = dict[coins[indexPath.row]]!
        
        self.navigationController?.pushViewController(targetViewController, animated: true)

    }
}
