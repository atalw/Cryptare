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

    @IBOutlet weak var currentAvailableLabel: UILabel!
    @IBOutlet weak var totalDepositedLabel: UILabel!
    @IBOutlet weak var totalWithdrawnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
