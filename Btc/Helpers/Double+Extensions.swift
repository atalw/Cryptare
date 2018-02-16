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
        
        for countryTuple in GlobalValues.countryList {
            if currency == countryTuple.1 {
                numberFormatter.locale = Locale.init(identifier: countryTuple.2)
            }
        }
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    var asBtcCurrency: String {
        return "₿ \(self)"
    }
    
    var asEthCurrency: String {
        return "\(self) ETH"
    }
}
