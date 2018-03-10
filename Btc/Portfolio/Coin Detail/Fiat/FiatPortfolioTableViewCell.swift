//
//  FiatPortfolioTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class FiatPortfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionTypeLabel: UILabel!
    
    @IBOutlet weak var currencyLogo: UIImageView!
    @IBOutlet weak var currencyName: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
