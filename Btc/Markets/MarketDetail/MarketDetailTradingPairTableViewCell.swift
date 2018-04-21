//
//  MarketDetailTradingPairTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class MarketDetailTradingPairTableViewCell: UITableViewCell {
  
  @IBOutlet weak var symbolImage: UIImageView! {
    didSet {
      symbolImage.loadSavedImage(coin: "BTC")
      symbolImage.contentMode =  .scaleAspectFit
    }
  }
  @IBOutlet weak var tradingPairLabel: UILabel! {
    didSet {
      tradingPairLabel.adjustsFontSizeToFitWidth = true
      tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var currentPriceLabel: UILabel! {
    didSet {
      currentPriceLabel.adjustsFontSizeToFitWidth = true
      currentPriceLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var volumeLabel: UILabel! {
    didSet {
      volumeLabel.adjustsFontSizeToFitWidth = true
      volumeLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
