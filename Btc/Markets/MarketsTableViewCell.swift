//
//  MarketsTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 20/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class MarketsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var exchangeTitleLabel: UILabel! {
    didSet {
      exchangeTitleLabel.adjustsFontSizeToFitWidth = true
      exchangeTitleLabel.theme_textColor = GlobalPicker.viewTextColor
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
