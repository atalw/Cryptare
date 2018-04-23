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
  
  static let currentThemeIndex = DefaultsKey<Int>("currentThemeIndex")
  
  static let selectedCountry = DefaultsKey<String>("selectedCountry")
  
  static let cryptoIcons = DefaultsKey<[String: Any]>("cryptoIcons")
  
  //Intros
  static let mainAppIntroComplete = DefaultsKey<Bool>("mainAppIntroComplete")
  static let mainPortfolioIntroComplete = DefaultsKey<Bool>("mainPortfolioIntroComplete")
  static let paidUserRestoreIntroComplete = DefaultsKey<Bool>("paidUserRestoreIntroComplete")
  
  // Dashboard
  static let dashboardFavourites = DefaultsKey<[String]>("dashboardFavourites")
  static let dashboardFavouritesFirstTab = DefaultsKey<Bool>("dashboardFavouritesFirstTab")
  
  // Coin Markets
  static let marketSettingsExist = DefaultsKey<Bool>("marketSettingsExist")
  static let marketSort = DefaultsKey<String>("marketSort")
  static let marketOrder = DefaultsKey<String>("marketOrder")
  
  // Charts
  static let chartSettingsExist = DefaultsKey<Bool>("chartSettingsExist")
  static let chartMode = DefaultsKey<String>("chartMode")
  static let xAxis = DefaultsKey<Bool>("xAxis")
  static let xAxisGridLinesEnabled = DefaultsKey<Bool>("xAxisGridLinesEnabled")
  static let yAxis = DefaultsKey<Bool>("yAxis")
  static let yAxisGridLinesEnabled = DefaultsKey<Bool>("yAxisGridLinesEnabled")
  
  // Markets
  static let favouriteMarkets = DefaultsKey<[String]>("favouriteMarkets")
  // chose this - favouritePairs -> ["BTC" : ["INR" : ["Koinex" : "koinex"], "USD": ["Coinbase": "coinbase"]], "ETH" : ["INR" : ["Koinex": "koinex"]]]
  // not gonna do this - favouritePairs -> ["Koinex: ["title" : "koinex", "pairs": [(BTC, INR), (ETH, INR)]]]
  static let favouritePairs = DefaultsKey<[String: Any]>("favouritePairs")
  
  // Alerts
  static let allCoinAlerts = DefaultsKey<[String: Any]>("allCoinAlerts")
  
  // News
  static let newsSettingsExist = DefaultsKey<Bool>("newsSettingsExist")
  static let newsSort = DefaultsKey<String>("newsSort")
  
  // Portfolio
  static let portfolioNames = DefaultsKey<[String]>("portfolioNames")
  static let cryptoPortfolioData = DefaultsKey<[String: Any]>("portfolioEntries")
  static let fiatPortfolioData = DefaultsKey<[String: Any]>("fiatPortfolioEntries")
  
  // IAP
  static let previousPaidUser = DefaultsKey<Bool>("previousPaidUser")
  static let removeAdsPurchased =  DefaultsKey<Bool>("removeAdsPurchased")
  static let unlockMarketsPurchased =  DefaultsKey<Bool>("unlockMarketsPurchased")
  static let multiplePortfoliosPurchased =  DefaultsKey<Bool>("multiplePortfoliosPurchased")
  static let unlockAllPurchased =  DefaultsKey<Bool>("unlockAllPurchased")
}
