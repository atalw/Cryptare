//
//  MarketTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 04/10/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class MarketTableViewCell: UITableViewCell {

    @IBOutlet weak var siteLabel: CustomUIButton! {
        didSet {
            siteLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            siteLabel.theme_setTitleColor(GlobalPicker.viewTextColor, forState: .normal)
        }
    }
    @IBOutlet weak var buyLabel: UILabel! {
        didSet {
            buyLabel.adjustsFontSizeToFitWidth = true
            buyLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var sellLabel: UILabel! {
        didSet {
            sellLabel.adjustsFontSizeToFitWidth = true
            sellLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
