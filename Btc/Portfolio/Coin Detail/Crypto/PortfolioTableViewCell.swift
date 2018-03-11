//
//  PortfolioTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 13/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transactionInfoLabel: UILabel!
    
    @IBOutlet weak var coinLogoImage: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    
    @IBOutlet weak var amountOfCoinsLabel: UILabel!
    @IBOutlet weak var costPerCoinLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!

    @IBOutlet weak var percentageChange: UILabel!
    @IBOutlet weak var percentageChangeView: UIView!

    @IBOutlet weak var tradingPairLabel: UILabel!
  
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
