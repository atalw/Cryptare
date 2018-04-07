//
//  LeftNavigationTableViewCell.swift
//  Btc
//
//  Created by Akshit Talwar on 04/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class LeftNavigationTableViewCell: UITableViewCell {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    open override func awakeFromNib() {
    }
    
    open func setData(_ data: Any?) {
        if let menuText = data as? String {
            self.titleLabel.text = menuText
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.background.theme_backgroundColor = GlobalPicker.navigationSelectedBackgroundColor
            self.titleLabel.theme_textColor = GlobalPicker.navigationTitleTextSelectedColor
        } else {
            self.background.theme_backgroundColor = GlobalPicker.mainBackgroundColor
            self.titleLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    // ignore the default handling
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.background.theme_backgroundColor = GlobalPicker.navigationSelectedBackgroundColor
            self.titleLabel.theme_textColor = GlobalPicker.navigationTitleTextSelectedColor
        }
        else {
            self.background.theme_backgroundColor = GlobalPicker.mainBackgroundColor
            self.titleLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
}
