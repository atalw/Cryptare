//
//  MarketDetailLinkTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class MarketDetailLinkTableViewCell: UITableViewCell {
  
  var link: String!
  
  @IBOutlet weak var socialTitleLabel: UILabel! {
    didSet {
      socialTitleLabel.adjustsFontSizeToFitWidth = true
      socialTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  @IBOutlet weak var linkLabel: UILabel! {
    didSet {
      linkLabel.adjustsFontSizeToFitWidth = true
      linkLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    if (self.isSelected == selected) {
      return
    }
    super.setSelected(selected, animated: animated)
    
    if let url = NSURL(string: self.link){ if #available(iOS 10.0, *) {
      UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    else {
      // Fallback on earlier versions
      UIApplication.shared.openURL(url as URL)
      }
      
//      FirebaseService.shared.news_article_tapped(url: self.link)
    }
    
    
  }
  
}
