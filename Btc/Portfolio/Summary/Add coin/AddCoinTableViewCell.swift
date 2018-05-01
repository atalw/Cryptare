//
//  AddCoinTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 27/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class AddCoinTableViewCell: UITableViewCell {
  
  @IBOutlet weak var coinImage: UIImageView! {
    didSet {
    }
  }
  @IBOutlet weak var coinNameLabel: UILabel! {
    didSet {
      coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
      coinNameLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var coinSymbolLabel: UILabel! {
    didSet {
      coinSymbolLabel.theme_textColor = GlobalPicker.viewTextColor
      coinSymbolLabel.adjustsFontSizeToFitWidth = true
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
