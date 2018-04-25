//
//  PairAlertTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class PairAlertTableViewCell: UITableViewCell {
  
  @IBOutlet weak var dateLabel: UILabel! {
    didSet {
      dateLabel.adjustsFontSizeToFitWidth = true
      dateLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var aboveLabel: UILabel! {
    didSet {
      aboveLabel.adjustsFontSizeToFitWidth = true
      aboveLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  @IBOutlet weak var thresholdPriceLabel: UILabel! {
    didSet {
      thresholdPriceLabel.adjustsFontSizeToFitWidth = true
      thresholdPriceLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  @IBOutlet weak var tradingPairLabel: UILabel! {
    didSet {
      tradingPairLabel.adjustsFontSizeToFitWidth = true
      tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  @IBOutlet weak var exchangeLabel: UILabel! {
    didSet {
      exchangeLabel.adjustsFontSizeToFitWidth = true
      exchangeLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  @IBOutlet weak var alertTypeLabel: UILabel! {
    didSet {
      alertTypeLabel.adjustsFontSizeToFitWidth = true
      alertTypeLabel.theme_textColor = GlobalPicker.viewAltTextColor
      
    }
  }
  
  @IBOutlet weak var isActiveSwitch: UISwitch! {
    didSet {
     
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
