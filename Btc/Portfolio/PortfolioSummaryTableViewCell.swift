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
    @IBOutlet weak var changePercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
