//
//  AddFiatTransactionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AddFiatTransactionViewController: UIViewController {
    
    var parentController: FiatPortfolioViewController!
    
    let greenColour = UIColor.init(hex: "2ECC71")
    let redColour = UIColor.init(hex: "E74C3C")
    let navyBlueColour = UIColor.init(hex: "46637F")
    
    var transactionType: String!

    var currency: String!
    var currentExchange: (String, String)!
    var amount: Double!
    var fees: Double!
    var date: Date!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addTransactionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        addTransactionButton.setBackgroundColor(UIColor.darkGray, forState: .disabled)
        
        addTransactionButton.setTitleColor(UIColor.white, for: .normal)
        addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        addTransactionButton.isEnabled = false
        
        if transactionType == "deposit" {
            addTransactionButton.setTitle("Add Buy Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(greenColour, forState: .normal)
            
        }
        else if transactionType == "withdraw" {
            addTransactionButton.setTitle("Add Sell Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(redColour, forState: .normal)
            
        }
    }

    func updateAddTransactionButtonStatus() {
        if currentExchange != nil && amount != nil &&
            fees != nil && time != nil && date != nil {
            addTransactionButton.isEnabled = true
        }
        else {
            addTransactionButton.isEnabled = false
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: Any) {
        
        let data: [String: Any] = ["type": transactionType,
                                   "exchange": currentExchange.0,
                                   "amount": amount,
                                   "fees": fees,
                                   "date": date,
                                   "time": time
        ]
        
        parentController.portfolioTableController.addPortfolioEntry(portfolioEntry: data)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination
        if let tableViewController = destinationVC as? AddFiatTransactionTableViewController {
            tableViewController.parentController = self
            tableViewController.currency = currency
        }
    }
    

}
