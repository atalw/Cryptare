//
//  FiatPortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 08/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class FiatPortfolioViewController: UIViewController {
    
    var parentController: PortfolioSummaryViewController!
    
    var portfolioTableController: FiatPortfolioTableViewController! // child vc
    
    var currency: String!
    var portfolioData: [[String: Any]] = []
    var portfolioName: String!
    
    var currentAvailable: Double! = 0
    var totalDeposited: Double! = 0
    var totalWithdrawn: Double! = 0

    @IBOutlet weak var summaryView: UIView! {
        didSet {
            summaryView.theme_backgroundColor = GlobalPicker.summaryViewBackgroundColor
        }
    }
    @IBOutlet weak var currencyNameLabel: UILabel! {
        didSet {
            currencyNameLabel.adjustsFontSizeToFitWidth = true
            currencyNameLabel.theme_textColor = GlobalPicker.viewTextColor

        }
    }
    @IBOutlet weak var currentAvailableLabel: UILabel! {
        didSet {
            currentAvailableLabel.adjustsFontSizeToFitWidth = true
            currentAvailableLabel.text = currentAvailable.asCurrency
            currentAvailableLabel.theme_textColor = GlobalPicker.viewTextColor

        }
    }
    @IBOutlet weak var totalDepositedLabel: UILabel! {
        didSet {
            totalDepositedLabel.adjustsFontSizeToFitWidth = true
            totalDepositedLabel.text = totalDeposited.asCurrency
            totalDepositedLabel.theme_textColor = GlobalPicker.viewTextColor

        }
    }
    @IBOutlet weak var totalWithdrawnLabel: UILabel! {
        didSet {
            totalWithdrawnLabel.adjustsFontSizeToFitWidth = true
            totalWithdrawnLabel.text = totalWithdrawn.asCurrency
            totalWithdrawnLabel.theme_textColor = GlobalPicker.viewTextColor

        }
    }
    
    @IBOutlet weak var totalAvailableDescLabel: UILabel! {
        didSet {
            totalAvailableDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalDepositedDescLabel: UILabel! {
        didSet {
            totalDepositedDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalWithdrawnDescLabel: UILabel! {
        didSet {
            totalWithdrawnDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      FirebaseService.shared.updateScreenName(screenName: "Fiat Portfolio", screenClass: "FiatPortfolioViewController")
      
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor

        // Do any additional setup after loading the view.
        for (_, symbol, _, name) in GlobalValues.countryList {
            if symbol == currency {
                currencyNameLabel.text = name
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentAvailable(value: -currentAvailable)
        updateTotalDeposited(value: -totalDeposited)
        updateTotalWithdrawn(value: -totalWithdrawn)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateCurrentAvailable(value: Double) {
        currentAvailable = currentAvailable + value
        DispatchQueue.main.async {
            self.currentAvailableLabel.text = self.currentAvailable.asCurrency
        }
    }
    
    func updateTotalDeposited(value: Double) {
        totalDeposited = totalDeposited + value
        DispatchQueue.main.async {
            self.totalDepositedLabel.text = self.totalDeposited.asCurrency
        }
    }
    
    func updateTotalWithdrawn(value: Double) {
        totalWithdrawn = totalWithdrawn + value
        DispatchQueue.main.async {
            self.totalWithdrawnLabel.text = self.totalWithdrawn.asCurrency
        }
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
            portfolioTableController.portfolioName = self.portfolioName
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
