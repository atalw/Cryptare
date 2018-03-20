//
//  AddTransactionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    var parentController: CryptoPortfolioViewController!
    
    let fiatPortfolioEntriesConstant = "fiatPortfolioEntries"
    
    let greenColour = UIColor.init(hex: "2ECC71")
    let redColour = UIColor.init(hex: "E74C3C")
    let navyBlueColour = UIColor.init(hex: "46637F")
    
    var transactionType: String!

    var coin: String!
    var currencies: [String] = []
    
    var currentTradingPair: (String, String)!
    var currentExchange: (String, String)!
    var costPerCoin: Double!
    var amountOfCoins: Double!
    var fees: Double!
    var time: Date!
    var date: Date!
    var deductFromHoldings: Bool!

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalTransactionCostLabel: UILabel!
    @IBOutlet weak var addTransactionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTransactionButton.setBackgroundColor(UIColor.darkGray, forState: .disabled)
        
        addTransactionButton.setTitleColor(UIColor.white, for: .normal)
        addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        addTransactionButton.isEnabled = false
        
        if transactionType == "buy" {
            addTransactionButton.setTitle("Add Buy Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(greenColour, forState: .normal)

        }
        else if transactionType == "sell" {
            addTransactionButton.setTitle("Add Sell Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(redColour, forState: .normal)

        }
        
        for (country, symbol, locale, name) in GlobalValues.countryList {
            currencies.append(symbol)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateAddTransactionButtonStatus() {
        
        if costPerCoin != nil && amountOfCoins != nil && fees != nil {
            let totalCost = (costPerCoin * amountOfCoins) + fees

            totalTransactionCostLabel.text = "Total cost of transaction is \(totalCost.asCurrency)"
        }
        else {
            totalTransactionCostLabel.text = "Total cost of transaction is \(0.0.asCurrency)"
        }
        
        if currentTradingPair != nil && currentExchange != nil &&
            costPerCoin != nil && amountOfCoins != nil &&
            fees != nil && time != nil && date != nil {
            addTransactionButton.isEnabled = true
        }
        else {
            addTransactionButton.isEnabled = false
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: Any) {
        
        let tradingPair = currentTradingPair.1
        let amount = costPerCoin*amountOfCoins
        
        let data: [String: Any] = ["type": transactionType,
                                   "coin": coin,
                                   "tradingPair": tradingPair,
                                   "exchange": currentExchange.0,
                                   "costPerCoin": costPerCoin,
                                   "amountOfCoins": amountOfCoins,
                                   "fees": fees,
                                   "date": date,
                                   "time": time
        ]
        
        parentController.portfolioTableController.addPortfolioEntry(portfolioEntry: data)
        
        if currencies.contains(tradingPair) {
            print(tradingPair, transactionType)
            var type: String!
            if transactionType == "buy" {
                type = "withdraw"
            }
            else {
                type = "deposit"
            }
            addFiatTransaction(currency: tradingPair, type: type, exchange: currentExchange.0, amount: amount, fees: fees, date: date, time: time)
        }
        else {
            print("not")
            var type: String!
            if transactionType == "buy" {
                type = "sell"
            }
            else {
                type = "buy"
            }
            let data: [String: Any] = ["type": type,
                                       "coin": tradingPair,
                                       "tradingPair": coin,
                                       "exchange": currentExchange.0,
                                       "costPerCoin": costPerCoin,
                                       "amountOfCoins": amountOfCoins,
                                       "fees": fees,
                                       "date": date,
                                       "time": time
                ]
            
            parentController.portfolioTableController.savePortfolioEntry(portfolioEntry: data)

        }
        
        self.navigationController?.popViewController(animated: true)

    }
    
    func addFiatTransaction(currency: String, type: String, exchange: String, amount: Double, fees: Double, date: Date, time: Date ) {
        print("type", type)
        if var data = defaults.data(forKey: fiatPortfolioEntriesConstant) {
            if var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[Int:Any]] {
                portfolioEntries.append([0: currency as Any,
                                         1: type as Any,
                                         2: exchange as Any,
                                         3: amount as Any,
                                         4: fees as Any,
                                         5: date as Any,
                                         6: time as Any
                                         ])
                
                let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
                defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
            }
        }
        else {
            var portfolioEntries: [[Int:Any]] = []
            
            portfolioEntries.append([0: currency as Any,
                                     1: type as Any,
                                     2: exchange as Any,
                                     3: amount as Any,
                                     4: fees as Any,
                                     5: date as Any,
                                     6: time as Any
                                     ])
            
            let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
            defaults.set(newData, forKey: fiatPortfolioEntriesConstant)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let addTransactionController = destinationVC as? AddTransactionTableViewController {
            addTransactionController.parentController = self
            addTransactionController.transactionType = self.transactionType
            addTransactionController.coin = self.coin
        }
    }
}
