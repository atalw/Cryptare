//
//  Transaction.swift
//  Cryptare
//
//  Created by Akshit Talwar on 12/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

class Transaction {
  
  var type: TransactionType
  var coin: String
  var tradingPair: String
  var exchange: String
  var costPerCoin: Double
  var amountOfCoins: Double
  var fees: Double
  var date: Date
  var totalCost: Double
  
  // for fiat transaction
  var currency: String
  var amount: Double
  
  init(type: TransactionType, coin: String, tradingPair: String, exchange: String, costPerCoin: Double, amountOfCoins: Double, fees: Double, date: Date) {
    self.type = type
    self.coin = coin
    self.tradingPair = tradingPair
    self.exchange = exchange
    self.costPerCoin = costPerCoin
    self.amountOfCoins = amountOfCoins
    self.fees = fees
    self.date = date
    
    
    //calculate
    self.totalCost = 0
  }
  
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
