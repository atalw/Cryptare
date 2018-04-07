//
//  CustomNewsTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 14/08/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CustomNewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel! {
        didSet {
            title.theme_textColor = GlobalPicker.viewTextColor
            title.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var pubDate: UILabel! {
        didSet {
            pubDate.theme_textColor = GlobalPicker.viewAltTextColor
            pubDate.adjustsFontSizeToFitWidth = true
        }
    }
    var link: String = ""


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if (self.isSelected == selected) {
            return
        }
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if let url = NSURL(string: self.link){ if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url as URL)
            } }
    }

}
