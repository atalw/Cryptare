//
//  IAPProducts.swift
//  Btc
//
//  Created by Akshit Talwar on 20/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

enum IAPProduct: String {
  case unlockProMode = "com.atalwar.Cryptare.UnlockProMode"
  case unlockProModeSixMonths = "com.atalwar.Cryptare.UnlockProModeSixMonths"
  case unlockProModeOneYear = "com.atalwar.Cryptare.UnlockProModeOneYear"
}

let IAPProductSet: Set<String> = [IAPProduct.unlockProMode.rawValue,
                                  IAPProduct.unlockProModeSixMonths.rawValue,
                                  IAPProduct.unlockProModeOneYear.rawValue]
