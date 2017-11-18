//
//  PortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 18/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    let numberFormatter = NumberFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var portfolioTableController: PortfolioTableViewController! // child vc
    
    var currentPortfolioValue: Double! = 0.0
    var totalInvested: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var totalPercentageLabel: UILabel!
    @IBOutlet weak var totalPercentageView: UIView!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    @IBOutlet weak var currentPortfolioValueLabel: UILabel!
    @IBOutlet weak var totalInvestedLabel: UILabel!
    @IBOutlet weak var totalAmountOfBitcoinLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        numberFormatter.numberStyle = .currency
        if GlobalValues.currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if GlobalValues.currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        currentPortfolioValueLabel.adjustsFontSizeToFitWidth = true
        totalInvestedLabel.adjustsFontSizeToFitWidth = true
        totalPercentageLabel.adjustsFontSizeToFitWidth = true
        totalPriceChangeLabel.adjustsFontSizeToFitWidth = true
        totalAmountOfBitcoinLabel.adjustsFontSizeToFitWidth = true

        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }
    @IBAction func addPortfolioAction(_ sender: Any) {
        portfolioTableController.showBulletin()
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
    
    func setTotalPortfolioValues() {
        currentPortfolioValueLabel.text = numberFormatter.string(from: NSNumber(value: currentPortfolioValue))
        totalInvestedLabel.text = numberFormatter.string(from: NSNumber(value: totalInvested))
        let change = currentPortfolioValue - totalInvested
        let percentageChange = (change / totalInvested) * 100
        var roundedPercentage  = Double(round(100*percentageChange)/100)
        if roundedPercentage.isNaN {
            roundedPercentage = 0
        }
        totalPercentageLabel.text = "\(roundedPercentage)%"
        
        totalPriceChangeLabel.text = numberFormatter.string(from: NSNumber(value: change))
        let roundedAmountOfBitcoin = Double(round(1000*totalAmountOfBitcoin!)/1000)
        totalAmountOfBitcoinLabel.text = "\(roundedAmountOfBitcoin) BTC"
        
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
        if let portfolioTableController = destinationVC as? PortfolioTableViewController {
            portfolioTableController.parentController = self
            self.portfolioTableController = portfolioTableController
        }
    }
 

}
