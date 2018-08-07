//
//  UITabBarController+Extensions.swift
//  Cryptare
//
//  Created by Akshit Talwar on 14/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

extension UITabBarController {
  func removeTabbarItemsText() {
    tabBar.items?.forEach {
      $0.title = ""
      $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
  }
}
