//
//  FiatTransactionEntryModel.swift
//  Cryptare
//
//  Created by Akshit Talwar on 10/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

class FiatTransactionEntryModel {
    
//    weak var delegate:
    
    var currency: String!
    
    var transactionType: String!
    
    var exchange: String!
    
    var amount: Double!
    var fees: Double!
    
    var date: Date!
    var time: Date!
    
    init(currency: String, transactionType: String, exchange: String,
         amount: Double, fees: Double, date: Date, time: Date) {
        
        self.currency = currency
        self.transactionType = transactionType
        self.exchange = exchange
        self.amount = amount
        self.fees = fees
        self.date = date
        self.time = time
    }
}
