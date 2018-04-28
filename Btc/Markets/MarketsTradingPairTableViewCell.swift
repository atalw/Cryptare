//
//  MarketsTradingPairTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 20/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class MarketsTradingPairTableViewCell: UITableViewCell {
  
  @IBOutlet weak var coinSymbolImage: UIImageView! {
    didSet {
      
    }
  }
  @IBOutlet weak var coinNameLabel: UILabel! {
    didSet {
      coinNameLabel.adjustsFontSizeToFitWidth = true
      coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var exchangeLabel: UILabel! {
    didSet {
      exchangeLabel.adjustsFontSizeToFitWidth = true
      exchangeLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var tradingPairLabel: UILabel! {
    didSet {
      tradingPairLabel.adjustsFontSizeToFitWidth = true
      tradingPairLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var currentPriceLabel: UILabel! {
    didSet {
      currentPriceLabel.adjustsFontSizeToFitWidth = true
      currentPriceLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var percentageChangeLabel: UILabel! {
    didSet {
      percentageChangeLabel.adjustsFontSizeToFitWidth = true
      percentageChangeLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
