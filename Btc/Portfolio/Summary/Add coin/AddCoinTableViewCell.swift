//
//  AddCoinTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 27/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class AddCoinTableViewCell: UITableViewCell {

    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
        coinSymbolLabel.theme_textColor = GlobalPicker.viewTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
