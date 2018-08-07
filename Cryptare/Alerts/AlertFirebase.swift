//
//  AlertFirebase.swift
//  Cryptare
//
//  Created by Akshit Talwar on 25/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//
//
//import Foundation
//import Firebase
//
//struct AlertModel: Codable {
//  var uid: String
//  var data: [AlertFirebase]
//}
//
//struct AlertFirebase: Codable {
//  var exchangeName: String
//  var coinData: [AlertCoinData]
//
////  // manual init
////  init(exchangeName: String, coinData: AlertCoinData) {
////    self.exchangeName = exchangeName
////    self.coinData = AlertCoinData(coin: <#T##String#>, pairData: <#T##AlertPairData#>)
////  }
//
//  // init with snapshot
//  init(snapshot: DataSnapshot, coinData: [AlertCoinData]) {
//    self.exchangeName = snapshot.key
//    self.coinData = coinData
//  }
////
////  // function for saving data
////  func toAnyObject() -> Any {
////    return [
////      "exchangeName": exchangeName,
////      coinData.toAnyObject()
////    ]
////  }
//}
//
//struct AlertCoinData: Codable {
//  var coin: String
//  var pairData: [AlertPairData]
//
//  // init with snapshot
//  init(snapshot: DataSnapshot, pairData: [AlertPairData]) {
//    self.coin = snapshot.key
//    self.pairData = pairData
//  }
////  // function for saving data
////  func toAnyObject() -> Any {
////    return [
////      "coin": coin,
////      pairData.toAnyObject()
////    ]
////  }
//}
//
//struct AlertPairData: Codable {
//  var pair: String
//  var alerts: [Alert]
//
//  // init with snapshot
//  init(snapshot: DataSnapshot, alerts: [Alert]) {
//    self.pair = snapshot.key
//    self.alerts = alerts
//  }
//
////  // function for saving data
////  func toAnyObject() -> Any {
////    return [
////      "pair": pair,
////      alerts.toAnyObject()
////    ]
////  }
//}
