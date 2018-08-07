//
//  FiatPortfolioTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class FiatPortfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionTypeLabel: UILabel! {
        didSet {
            transactionTypeLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var currencyLogo: UIImageView! {
        didSet {
            
        }
    }
    @IBOutlet weak var currencyName: UILabel! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var amountLabel: UILabel! {
        didSet {
            amountLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var feesLabel: UILabel! {
        didSet {
            feesLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var amountDescLabel: UILabel! {
        didSet {
            amountDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var feesDescLabel: UILabel! {
        didSet {
            feesDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var dateDescLabel: UILabel! {
        didSet {
            dateDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var timeDescLabel: UILabel! {
        didSet {
            timeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
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
