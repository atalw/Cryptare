//
//  IAPProducts.swift
//  Btc
//
//  Created by Akshit Talwar on 20/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

enum IAPProduct: String {
    case removeAds = "com.atalwar.Cryptare.RemoveAds"
    case unlockMarkets = "com.atalwar.Cryptare.UnlockMarkets"
    case multiplePortfolios = "com.atalwar.Cryptare.MultiplePortfolios"
    case unlockAll = "com.atalwar.Cryptare.UnlockAll"
    case unlockProMode = "com.atalwar.Cryptare.UnlockProMode"

}

enum IAPProductDev: String {
    case removeAds = "com.atalwar.Cryptare.dev.RemoveAds"
    case unlockMarkets = "com.atalwar.Cryptare.dev.UnlockMarkets"
}
