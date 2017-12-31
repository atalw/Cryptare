//
//  Double+Extensions.swift
//  Btc
//
//  Created by Akshit Talwar on 31/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation

extension Double {
    
    var asCurrency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        let currency = GlobalValues.currency!
        
        if currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        else if currency == "EUR" {
            numberFormatter.locale = Locale.init(identifier: "nl_NL")
        }
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
