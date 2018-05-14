//
//  FiatTransaction.swift
//  Cryptare
//
//  Created by Akshit Talwar on 12/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

class FiatTransaction {
  
  var type: TransactionType
  var exchange: String
  var fees: Double
  var date: Date
  var totalCost: Double
  
  // for fiat transaction
  var currency: String
  var amount: Double
  
  init(type: TransactionType, currency: String, exchange: String, amount: Double, fees: Double, date: Date) {
    self.type = type
    self.currency = currency
    self.amount = amount
    self.exchange = exchange
    self.fees = fees
    self.date = date
    
    //calculate
    self.totalCost = 0
  }
}
