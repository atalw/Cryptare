//
//  CoinTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 18/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet weak var coinRank: UILabel!
    @IBOutlet weak var coinSymbolImage: UIImageView!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinCurrentValueLabel: UILabel!
    @IBOutlet weak var coinTimestampLabel: UILabel!
    @IBOutlet weak var coinPercentageChangeLabel: UILabel!
    @IBOutlet weak var coinPriceChangeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        self.coinRank.theme_textColor = GlobalPicker.viewTextColor
        self.coinSymbolLabel.theme_textColor = GlobalPicker.viewTextColor
        self.coinNameLabel.theme_textColor = GlobalPicker.viewAltTextColor
        self.coinCurrentValueLabel.theme_textColor = GlobalPicker.viewTextColor
        self.coinTimestampLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
