//
//  PortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 18/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CryptoPortfolioViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var portfolioTableController: CryptoPortfolioTableViewController! // child vc
    
    var currentPortfolioValue: Double! = 0.0
    var totalInvested: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    var coin: String!
    var portfolioData: [[String: Any]] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentPortfolioValueLabel: UILabel!
    @IBOutlet weak var totalInvestedLabel: UILabel!
    @IBOutlet weak var totalAmountOfBitcoinLabel: UILabel!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    @IBOutlet weak var totalPercentageLabel: UILabel!
    @IBOutlet weak var totalPercentageView: UIView!
    @IBOutlet weak var sortView: UIView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBAction func addPortfolioAction(_ sender: Any) {
        portfolioTableController.showAddBuyBulletin()
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "hh:mm a"
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        currentPortfolioValueLabel.adjustsFontSizeToFitWidth = true
        totalInvestedLabel.adjustsFontSizeToFitWidth = true
        totalPercentageLabel.adjustsFontSizeToFitWidth = true
        totalPriceChangeLabel.adjustsFontSizeToFitWidth = true
        totalAmountOfBitcoinLabel.adjustsFontSizeToFitWidth = true
        
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
            portfolioTableController.portfolioData = self.portfolioData
            self.portfolioTableController = portfolioTableController
        }
        
        if let addTransactionController = destinationVC as? AddTransactionViewController {
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
    }
 

}
