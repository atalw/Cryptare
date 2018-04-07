//
//  PortfolioSummaryTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 21/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinHoldingsLabel: UILabel!
    @IBOutlet weak var coinCurrentValueLabel: UILabel!
    
    @IBOutlet weak var changePercentageLabel: UILabel!
    @IBOutlet weak var changeCostLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        coinSymbolLabel.theme_textColor = GlobalPicker.viewTextColor
        coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
        coinHoldingsLabel.theme_textColor = GlobalPicker.viewAltTextColor
        coinCurrentValueLabel.theme_textColor = GlobalPicker.viewAltTextColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
