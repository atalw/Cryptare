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
  
  func asSelectedCurrency(currency: String) -> String {
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    
    for countryTuple in GlobalValues.countryList {
      if currency == countryTuple.1 {
        numberFormatter.locale = Locale.init(identifier: countryTuple.2)
      }
    }
    return numberFormatter.string(from: NSNumber(value: self))!
  }
  
  var asBtcCurrency: String {
    var decimalValue = Decimal(self)
    var result = Decimal()
    NSDecimalRound(&result, &decimalValue, 8, .plain)
    return "₿ \(result)"
  }
  
  var asEthCurrency: String {
    var decimalValue = Decimal(self)
    var result = Decimal()
    NSDecimalRound(&result, &decimalValue, 8, .plain)
    return "\(result) ETH"
  }
}
