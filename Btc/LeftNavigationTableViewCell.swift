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
    
    class var identifier: String { return String.className(self) }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {
    }
    
    open func setup() {
    }
    
    open class func height() -> CGFloat {
        return 48
    }
    
    open func setData(_ data: Any?) {
        self.background.backgroundColor = UIColor.white
        if let menuText = data as? String {
            self.titleLabel.text = menuText
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.background.backgroundColor = UIColor.init(hex: "2980B9")
            self.titleLabel.textColor = UIColor.white
        } else {
            self.background.backgroundColor = UIColor.white
            self.titleLabel.textColor = UIColor.black
        }
    }
    
    // ignore the default handling
    override open func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.background.backgroundColor = UIColor.init(hex: "2980B9")
            self.titleLabel.textColor = UIColor.white
        }
        else {
            self.background.backgroundColor = UIColor.white
            self.titleLabel.textColor = UIColor.black
        }
    }
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.characters.count
    }
}
