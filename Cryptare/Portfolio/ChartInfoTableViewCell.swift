//
//  ChartInfoTableViewCell.swift
//  Cryptare
//
//  Created by Akshit Talwar on 23/09/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftTheme

class ChartInfoTableViewCell: UITableViewCell {

  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var fullNameLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var valueLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    self.fullNameLabel?.theme_textColor = GlobalPicker.viewTextColor
    self.titleLabel?.theme_textColor = GlobalPicker.viewAltTextColor
    self.valueLabel?.theme_textColor = GlobalPicker.viewTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
