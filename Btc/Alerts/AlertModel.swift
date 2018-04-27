//
//  AlertModel.swift
//  Cryptare
//
//  Created by Akshit Talwar on 23/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import Firebase

class Alert {
  
  var date: String
  var isAbove: Bool
  var thresholdPrice: Double
  var tradingPair: (String, String)
  var exchange: (String, String) // (name, databaseTitle)
  var isActive: Bool
  var type: String // onetime, persistent
  var databaseTitle: String
  
  init(date: String, isAbove: Bool, thresholdPrice: Double, tradingPair: (String, String), exchange: (String, String), isActive: Bool, type: String, databaseTitle: String) {
    self.date = date
    self.isAbove = isAbove
    self.thresholdPrice = thresholdPrice
    self.tradingPair = tradingPair
    self.exchange = exchange
    self.isActive = isActive
    self.type = type
    self.databaseTitle = databaseTitle
  }
  
//  init(snapshot: DataSnapshot) {
//
//    var date: String?
//    var isAbove: Bool?
//    var thresholdPrice: Double?
//    var isActive: Bool?
//    var type: String?
//
//    if let snapshotValue = snapshot.value as? [String: Any] {
//      date = snapshotValue["date"] as? String
//      isAbove = snapshotValue["isAbove"] as? Bool
//      thresholdPrice = snapshotValue["thresholdPrice"] as? Double
//      //    let tradingPair = snapshot.value(forKey: "tradingPair") as? String
//      //    let exchange = snapshot.value(forKey: "exchange") as? String
//      isActive = snapshotValue["isActive"] as? Bool
//      type = snapshotValue["type"] as? String
//    }
//
//    self.date = date ?? ""
//    self.isAbove = isAbove ?? false
//    self.thresholdPrice = thresholdPrice ?? 0.0
////    self.tradingPair = tradingPair ?? ""
////    self.exchange = exchange ?? ""
//    self.isActive = isActive ?? false
//    self.type = type ?? ""
//  }
}
