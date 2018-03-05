//
//  PortfolioViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 18/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import YNDropDownMenu

class PortfolioViewController: UIViewController {
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var portfolioTableController: PortfolioTableViewController! // child vc
    
    var currentPortfolioValue: Double! = 0.0
    var totalInvested: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    var coin: String!
    var portfolioData: [[String: Any]] = []
    
    var sortDropDownView: YNDropDownMenu!
    
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
//    @IBAction func addBuyPortflioAction(_ sender: Any) {
//        portfolioTableController.showAddBuyBulletin()
//    }
//    @IBAction func addSellPortfolioAction(_ sender: Any) {
//       portfolioTableController.showAddSellBulletin()
//    }
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let sortDropDownViews = Bundle.main.loadNibNamed("SortDropDownViews", owner: nil, options: nil) as? [UIView]
        
        var sortDropDownMenu: YNDropDownMenu!
        
        if let _sortDropDownViews = sortDropDownViews {
            // Inherit YNDropDownView if you want to hideMenu in your dropDownViews
            sortDropDownMenu = YNDropDownMenu(frame: CGRect(x: 0, y: sortView.frame.minY, width: UIScreen.main.bounds.size.width, height: 40), dropDownViews: _sortDropDownViews, dropDownViewTitles: ["Amount", "Date", "Money", "Change"])
            let FFA409 = UIColor.init(red: 255/255, green: 164/255, blue: 9/255, alpha: 1.0)
            
            //            view.setImageWhen(normal: UIImage(named: "arrow_nor"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow_dim"))
            
            sortDropDownMenu.setLabelColorWhen(normal: .black, selected: FFA409, disabled: .gray)
            
            sortDropDownMenu.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
            
            sortDropDownMenu.backgroundBlurEnabled = true
            sortDropDownMenu.bottomLine.isHidden = false
            // Add custom blurEffectView
            let backgroundView = UIView()
            backgroundView.backgroundColor = .black
            sortDropDownMenu.blurEffectView = backgroundView
            sortDropDownMenu.blurEffectViewAlpha = 0.7
            
            // Open and Hide Menu
            sortDropDownMenu.normalSelected(at: 0)
            sortDropDownMenu.setBackgroundColor(color: UIColor.white)
            
            // important - add to stack view to correctly place drop down view in view
//            self.mainStackView.addSubview(sortDropDownMenu)
        }
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
        if let portfolioTableController = destinationVC as? PortfolioTableViewController {
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
                }
                
            }
            
            
        }
    }
 

}
