////
////  CryptoTransaction.swift
////  Cryptare
////
////  Created by Akshit Talwar on 12/05/2018.
////  Copyright © 2018 atalw. All rights reserved.
////
//
//import Foundation
//
//class CryptoTransaction {
//  
//  var type: TransactionType
//  var coin: String
//  var pair: String
//  var exchangeName: String
//  var exchangeDbTitle: String
//  var costPerCoin: Double
//  var amountOfCoins: Double
//  var fees: Double
//  var date: Date
//  var totalCost: Double
//  var totalCostUSD: Double
//  
//  let dateFormatter = DateFormatter()
//  
//  init(type: TransactionType, coin: String, pair: String, exchange: (String, String), costPerCoin: Double, amountOfCoins: Double, fees: Double, date: Date) {
//    dateFormatter.dateFormat =  "yyyy-MM-dd hh:mm a"
//
//    self.type = type
//    self.coin = coin
//    self.pair = pair
//    self.exchangeName = exchange.0
//    self.exchangeDbTitle = exchange.1
//    self.costPerCoin = costPerCoin
//    self.amountOfCoins = amountOfCoins
//    self.fees = fees
//    self.date = date
//    
//    
//    
//    
//    //calculate
//    self.totalCost = 0
//    
//    if pair == "USD" || pair == "USDT" {
//      totalCostUSD = totalCost
//    }
//    else {
//      // check if pair is fiat or crypto
//      // if fiat get exchange rate for fixer
//      // else get price for firebase
//      
//    }
//  }
//  
////  func returnAsDictionary() -> [String: Any] {
////    let dateString = dateFormatter.string(from: date)
////    if type == TransactionType.buy || type == TransactionType.sell {
////      return ["type": type,
////              "coin": coin,
////              "tradingPair": tradingPair,
////              "exchange": exchange,
////              "costPerCoin": costPerCoin,
////              "amountOfCoins": amountOfCoins,
////              "fees": fees,
////              "totalCost": totalCost,
////              "date": dateString]
////    }
////  }
//  
//}
