//
//  PortfolioTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 13/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinLogoImage: UIImageView!
    @IBOutlet weak var amountOfBitcoinLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var dateOfPurchaseLabel: UILabel!
    @IBOutlet weak var percentageChange: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var percentageChangeView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
