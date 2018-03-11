//
//  FiatPortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 08/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class FiatPortfolioViewController: UIViewController {
    
    var portfolioTableController: FiatPortfolioTableViewController! // child vc
    
    var currency: String!
    var portfolioData: [[String: Any]] = []
    
    var currentAvailable: Double! = 0
    var totalDeposited: Double! = 0
    var totalWithdrawn: Double! = 0

    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currentAvailableLabel: UILabel!
    @IBOutlet weak var totalDepositedLabel: UILabel!
    @IBOutlet weak var totalWithdrawnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for (country, symbol, locale, name) in GlobalValues.countryList {
            if symbol == currency {
                currencyNameLabel.text = name
                break
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentAvailable = 0
        totalDeposited = 0
        totalWithdrawn = 0
    }
    
    func addToTotalDeposited(value: Double) {
        totalDeposited = totalDeposited + value
        currentAvailable = currentAvailable + value
        setTotalValues()
    }
    
    func addToTotalWithdrawn(value: Double) {
        totalWithdrawn = totalWithdrawn + value
        currentAvailable = currentAvailable - value
        setTotalValues()
    }
    
    func removeDepositedEntry(value: Double) {
        totalDeposited = totalDeposited - value
        currentAvailable = currentAvailable - value
        setTotalValues()
    }
    
    func removeWithdrawnEntry(value: Double) {
        totalWithdrawn = totalWithdrawn - value
        currentAvailable = currentAvailable + value
        setTotalValues()
    }

    func setTotalValues() {
        currentAvailableLabel.text = currentAvailable.asCurrency
        totalDepositedLabel.text = totalDeposited.asCurrency
        totalWithdrawnLabel.text = totalWithdrawn.asCurrency
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination
        if let portfolioTableController = destinationVC as? FiatPortfolioTableViewController {
            portfolioTableController.parentController = self
            portfolioTableController.currency = self.currency
            portfolioTableController.portfolioData = self.portfolioData
            self.portfolioTableController = portfolioTableController
        }
        
        if let addTransactionController = destinationVC as? AddFiatTransactionViewController {
            if let button = sender as? UIButton {
                if let title = button.titleLabel?.text {
                    if title == "Deposit" {
                        addTransactionController.transactionType = "deposit"
                    }
                    else if title == "Withdraw" {
                        addTransactionController.transactionType = "withdraw"
                    }
                    addTransactionController.currency = self.currency
                    addTransactionController.parentController = self
                }
                
            }
        }
    }
    

}
