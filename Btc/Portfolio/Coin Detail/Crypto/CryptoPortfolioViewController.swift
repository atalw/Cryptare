//
//  PortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 18/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CryptoPortfolioViewController: UIViewController {
    
    var parentController: PortfolioSummaryViewController!
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var portfolioTableController: CryptoPortfolioTableViewController! // child vc
    
    var currentPortfolioValue: Double! = 0.0
    var totalInvested: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    var coin: String!
    var coinPrice: Double!
    var portfolioData: [[String: Any]] = []
    var portfolioName: String!
    
    // MARK: - IBOutlets
    @IBOutlet weak var summaryView: UIView! {
        didSet {
            summaryView.theme_backgroundColor = GlobalPicker.summaryViewBackgroundColor
        }
    }
    @IBOutlet weak var currentPortfolioValueLabel: UILabel! {
        didSet {
            currentPortfolioValueLabel.adjustsFontSizeToFitWidth = true
            currentPortfolioValueLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalInvestedLabel: UILabel! {
        didSet {
            totalInvestedLabel.adjustsFontSizeToFitWidth = true
            totalInvestedLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalAmountOfBitcoinLabel: UILabel! {
        didSet {
            totalAmountOfBitcoinLabel.adjustsFontSizeToFitWidth = true
            totalAmountOfBitcoinLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalPriceChangeLabel: UILabel! {
        didSet {
            totalPriceChangeLabel.adjustsFontSizeToFitWidth = true
            totalPriceChangeLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalPercentageLabel: UILabel! {
        didSet {
            totalPercentageLabel.adjustsFontSizeToFitWidth = true
            totalPercentageLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalPercentageView: UIView! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentPortfolioDescLabel: UILabel! {
        didSet {
            currentPortfolioDescLabel.adjustsFontSizeToFitWidth = true
            currentPortfolioDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalHoldingsDescLabel: UILabel! {
        didSet {
            totalHoldingsDescLabel.adjustsFontSizeToFitWidth = true
            totalHoldingsDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalInvestedDescLabel: UILabel! {
        didSet {
            totalInvestedDescLabel.adjustsFontSizeToFitWidth = true
            totalInvestedDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalChangeDescLabel: UILabel! {
        didSet {
            totalChangeDescLabel.adjustsFontSizeToFitWidth = true
            totalChangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "hh:mm a"
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        setTotalPortfolioValues()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentPortfolioValue = 0
        totalInvested = 0
        totalAmountOfBitcoin = 0
    }
    
    // MARK: - Total Portfolio functions
    
    func addTotalPortfolioValues(amountOfBitcoin: Double, cost: Double, currentValue: Double) {
        currentPortfolioValue = currentPortfolioValue + currentValue
        totalInvested = totalInvested + cost
        totalAmountOfBitcoin = totalAmountOfBitcoin + amountOfBitcoin
        setTotalPortfolioValues()
    }
    
    func subtractTotalPortfolioValues(amountOfBitcoin: Double, cost: Double, currentValue: Double) {
        currentPortfolioValue = currentPortfolioValue - currentValue
        totalInvested = totalInvested - cost
        totalAmountOfBitcoin = totalAmountOfBitcoin - amountOfBitcoin
        setTotalPortfolioValues()
    }
    
    func addSellTotalPortfolioValues(amountOfBitcoin: Double, cost: Double, currentValue: Double) {
        currentPortfolioValue = currentPortfolioValue - currentValue
        totalAmountOfBitcoin = totalAmountOfBitcoin - amountOfBitcoin
        totalInvested = totalInvested - cost
        setTotalPortfolioValues()
    }
    
    func subtractSellTotalPortfolioValues(amountOfBitcoin: Double, cost: Double, currentValue: Double) {
        currentPortfolioValue = currentPortfolioValue + currentValue
        totalInvested = totalInvested + cost
        totalAmountOfBitcoin = totalAmountOfBitcoin + amountOfBitcoin
        setTotalPortfolioValues()
    }
    
    func setTotalPortfolioValues() {
        currentPortfolioValueLabel.text = currentPortfolioValue.asCurrency
        totalInvestedLabel.text = totalInvested.asCurrency
        let absTotalInvested = abs(totalInvested)
        let change = currentPortfolioValue - totalInvested
        let percentageChange = (change / absTotalInvested) * 100
        var roundedPercentage  = Double(round(100*percentageChange)/100)
        if roundedPercentage.isNaN {
            roundedPercentage = 0
        }
        totalPercentageLabel.text = "\(roundedPercentage)%"
        
        totalPriceChangeLabel.text = change.asCurrency
        let roundedAmountOfBitcoin = Double(round(1000*totalAmountOfBitcoin!)/1000)
        totalAmountOfBitcoinLabel.text = "\(roundedAmountOfBitcoin) \(self.coin!)"
        
        if roundedPercentage > 0 {
            totalPercentageView.backgroundColor = greenColour
        }
        else if roundedPercentage == 0 {
            totalPercentageView.backgroundColor = UIColor.lightGray
        }
        else {
            totalPercentageView.backgroundColor = redColour
        }
    }
    
    // MARK: - Navigation

//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination
        if let portfolioTableController = destinationVC as? CryptoPortfolioTableViewController {
            portfolioTableController.parentController = self
            portfolioTableController.coin = self.coin
            portfolioTableController.portfolioName = self.portfolioName
            portfolioTableController.portfolioData = self.portfolioData
            portfolioTableController.coinPrice = self.coinPrice
            self.portfolioTableController = portfolioTableController
        }
        
        else if let addTransactionController = destinationVC as? AddTransactionViewController {
            if let button = sender as? UIButton {
                if let title = button.titleLabel?.text {
                    if title == "Buy" {
                        addTransactionController.transactionType = "buy"
                    }
                    else if title == "Sell" {
                        addTransactionController.transactionType = "sell"
                    }
                    addTransactionController.coin = self.coin
                    addTransactionController.parentController = self
                }
                
            }
        }
        else if let portfolioSummaryController = destinationVC as? PortfolioSummaryViewController {
            print("here")
        }
    }
 

}
