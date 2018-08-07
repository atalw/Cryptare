//
//  ColourThemes.swift
//  Cryptare
//
//  Created by Akshit Talwar on 06/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import SwiftTheme
import SwiftyUserDefaults

enum ColourThemes: Int {
    case light = 0
    case night = 1
    
    static func switchTheme(theme: ColourThemes) {
        ThemeManager.setTheme(index: theme.rawValue)
        Defaults[.currentThemeIndex] = theme.rawValue
    }
}
