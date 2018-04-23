//
//  AlertModel.swift
//  Cryptare
//
//  Created by Akshit Talwar on 23/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

class Alert {
  
  var date: String
  var isAbove: Bool
  var thresholdPrice: Double
  var tradingPair: (String, String)
  var exchange: (String, String) // (name, databaseTitle)
  var isActive: Bool
  var type: String // onetime, persistent
  
  init(date: String, isAbove: Bool, thresholdPrice: Double, tradingPair: (String, String), exchange: (String, String), isActive: Bool, type: String) {
    self.date = date
    self.isAbove = isAbove
    self.thresholdPrice = thresholdPrice
    self.tradingPair = tradingPair
    self.exchange = exchange
    self.isActive = isActive
    self.type = type
  }
}
