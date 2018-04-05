//
//  UIBarBarButtonItem+Extensions.swift
//  Cryptare
//
//  Created by Akshit Talwar on 23/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        
        let currWidth = barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        return barButtonItem
    }
}
