//
//  FiatTransactionEntryModel.swift
//  Cryptare
//
//  Created by Akshit Talwar on 10/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation

class FiatTransactionEntryModel {
    
    var currency: String!
    
    var type: String!
    
    var exchange: String!
    
    var amount: Double!
    var fees: Double!
    
    var date: Date!
    
    init(currency: String, type: String, exchange: String,
         amount: Double, fees: Double, date: Date) {
        
        self.currency = currency
        self.type = type
        self.exchange = exchange
        self.amount = amount
        self.fees = fees
        self.date = date
    }
}
