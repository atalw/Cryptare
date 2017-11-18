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
    
    let numberFormatter = NumberFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var portfolioTableController: PortfolioTableViewController! // child vc
    
    var currentPortfolioValue: Double! = 0.0
    var totalInvested: Double! = 0.0
    var totalAmountOfBitcoin: Double! = 0.0
    
    var sortDropDownView: YNDropDownMenu!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var totalPercentageLabel: UILabel!
    @IBOutlet weak var totalPercentageView: UIView!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    @IBOutlet weak var currentPortfolioValueLabel: UILabel!
    @IBOutlet weak var totalInvestedLabel: UILabel!
    @IBOutlet weak var totalAmountOfBitcoinLabel: UILabel!
    @IBOutlet weak var sortView: UIView!
    

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let sortDropDownViews = Bundle.main.loadNibNamed("SortDropDownViews", owner: nil, options: nil) as? [UIView]
        
        if let _sortDropDownViews = sortDropDownViews {
            // Inherit YNDropDownView if you want to hideMenu in your dropDownViews
            //            let frame = sortView.convert(sortView.bounds, to: self.view)
            let sortDropDownView = YNDropDownMenu(frame: CGRect(x: 0, y: sortView.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: 40), dropDownViews: _sortDropDownViews, dropDownViewTitles: ["Bitcoin", "Date", "Money", "Change"])
            let FFA409 = UIColor.init(red: 255/255, green: 164/255, blue: 9/255, alpha: 1.0)
            
            //            view.setImageWhen(normal: UIImage(named: "arrow_nor"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow_dim"))
            
            sortDropDownView.setLabelColorWhen(normal: .black, selected: FFA409, disabled: .gray)
            
            sortDropDownView.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
            
            sortDropDownView.backgroundBlurEnabled = true
            sortDropDownView.bottomLine.isHidden = false
            // Add custom blurEffectView
            let backgroundView = UIView()
            backgroundView.backgroundColor = .black
            sortDropDownView.blurEffectView = backgroundView
            sortDropDownView.blurEffectViewAlpha = 0.7
            
            // Open and Hide Menu
            sortDropDownView.alwaysSelected(at: 0)
            sortDropDownView.setBackgroundColor(color: UIColor.white)
            
//            self.view.addSubview(sortDropDownView)
        }
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