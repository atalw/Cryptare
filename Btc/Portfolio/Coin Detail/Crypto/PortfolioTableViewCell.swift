//
//  PortfolioTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 13/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transactionInfoLabel: UILabel! {
        didSet {
            transactionInfoLabel.adjustsFontSizeToFitWidth = true
            transactionInfoLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var coinLogoImage: UIImageView! {
        didSet {
            
        }
    }
    @IBOutlet weak var coinNameLabel: UILabel!
    
    @IBOutlet weak var amountOfCoinsLabel: UILabel! {
        didSet {
            amountOfCoinsLabel.adjustsFontSizeToFitWidth = true
            amountOfCoinsLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var costPerCoinLabel: UILabel! {
        didSet {
            costPerCoinLabel.adjustsFontSizeToFitWidth = true
            costPerCoinLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalCostLabel: UILabel! {
        didSet {
            totalCostLabel.adjustsFontSizeToFitWidth = true
            totalCostLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }

    @IBOutlet weak var percentageChange: UILabel! {
        didSet {
            percentageChange.adjustsFontSizeToFitWidth = true
//            percentageChange.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var percentageChangeView: UIView!

    @IBOutlet weak var tradingPairLabel: UILabel! {
        didSet {
            tradingPairLabel.adjustsFontSizeToFitWidth = true
            tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
  
    @IBOutlet weak var currentValueLabel: UILabel! {
        didSet {
            currentValueLabel.adjustsFontSizeToFitWidth = true
            currentValueLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var feesLabel: UILabel! {
        didSet {
            feesLabel.adjustsFontSizeToFitWidth = true
            feesLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    @IBOutlet weak var costPerCoinDescLabel: UILabel! {
        didSet {
            costPerCoinDescLabel.adjustsFontSizeToFitWidth = true
            costPerCoinDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalCostDescLabel: UILabel! {
        didSet {
            totalCostDescLabel.adjustsFontSizeToFitWidth = true
            totalCostDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var percentageChangeDescLabel: UILabel! {
        didSet {
            percentageChangeDescLabel.adjustsFontSizeToFitWidth = true
            percentageChangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var feesDescLabel: UILabel! {
        didSet {
            feesDescLabel.adjustsFontSizeToFitWidth = true
            feesDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var marketValueDescLabel: UILabel! {
        didSet {
            marketValueDescLabel.adjustsFontSizeToFitWidth = true
            marketValueDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var dataView: UIView! {
        didSet {
            dataView.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
