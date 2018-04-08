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
            amountOfCoinsLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var costPerCoinLabel: UILabel! {
        didSet {
            costPerCoinLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var totalCostLabel: UILabel! {
        didSet {
            totalCostLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }

    @IBOutlet weak var percentageChange: UILabel! {
        didSet {
            percentageChange.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var percentageChangeView: UIView!

    @IBOutlet weak var tradingPairLabel: UILabel! {
        didSet {
            tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
  
    @IBOutlet weak var currentValueLabel: UILabel! {
        didSet {
            currentValueLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var feesLabel: UILabel! {
        didSet {
            feesLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    @IBOutlet weak var costPerCoinDescLabel: UILabel! {
        didSet {
            costPerCoinDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var totalCostDescLabel: UILabel! {
        didSet {
            totalCostDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var percentageChangeDescLabel: UILabel! {
        didSet {
            percentageChangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var feesDescLabel: UILabel! {
        didSet {
            feesDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var marketValueDescLabel: UILabel! {
        didSet {
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
