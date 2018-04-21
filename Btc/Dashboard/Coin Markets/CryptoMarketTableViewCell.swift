//
//  CryptoMarketTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 08/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class CryptoMarketTableViewCell: UITableViewCell {

    @IBOutlet weak var exchangeName: UILabel!
    @IBOutlet weak var lastPrice: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
