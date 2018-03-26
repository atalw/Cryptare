//
//  UserDefaultsKeys.swift
//  Cryptare
//
//  Created by Akshit Talwar on 26/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let portfolioData = DefaultsKey<[String: Any]>("portfolioEntries")
    
    static let selectedCountry = DefaultsKey<String>("selectedCountry")
    static let mainIntroComplete = DefaultsKey<Bool>("mainIntroComplete")

    
    // Dashboard
    static let dashboardFavourites = DefaultsKey<[String]>("dashboardFavourites")
    static let dashboardFavouritesFirstTab = DefaultsKey<Bool>("dashboardFavouritesFirstTab")

    // Charts
    static let chartSettingsExist = DefaultsKey<Bool>("chartSettingsExist")
    static let chartMode = DefaultsKey<String>("chartMode")
    static let xAxis = DefaultsKey<Bool>("xAxis")
    static let xAxisGridLinesEnabled = DefaultsKey<Bool>("xAxisGridLinesEnabled")
    static let yAxis = DefaultsKey<Bool>("yAxis")
    static let yAxisGridLinesEnabled = DefaultsKey<Bool>("yAxisGridLinesEnabled")
    
    // Markets
    static let marketSettingsExist = DefaultsKey<Bool>("marketSettingsExist")
    static let marketSort = DefaultsKey<String>("marketSort")
    static let marketOrder = DefaultsKey<String>("marketOrder")

    // News
    static let newsSettingsExist = DefaultsKey<Bool>("newsSettingsExist")
    static let newsSort = DefaultsKey<String>("newsSort")
    
    // IAP
    static let previousPaidUser = DefaultsKey<Bool>("previousPaidUser")
    static let removeAdsPurchased =  DefaultsKey<Bool>("removeAdsPurchased")
    static let unlockMarketsPurchased =  DefaultsKey<Bool>("unlockMarketsPurchased")
    static let multiplePortfoliosPurchased =  DefaultsKey<Bool>("multiplePortfoliosPurchased")
    static let unlockAllPurchased =  DefaultsKey<Bool>("unlockAllPurchased")
}
