//
//  PortfolioFiatSummaryTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 10/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class PortfolioFiatSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyLogoImage: UIImageView!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var holdingsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
