//
//  Promise+Extensions.swift
//  Cryptare
//
//  Created by Akshit Talwar on 15/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import Promises
import Alamofire
import SwiftyJSON

func getExchangeRateUSD(symbol: String) -> Promise<Double> {
  let exchangeURL = URL(string: "https://ratesapi.io/api/latest?symbols=USD&base=\(symbol)")!
  
  return Promise { fulfill, reject in
    Alamofire.request(exchangeURL).responseJSON { (response) in
      if let result = response.result.value {
        let json = JSON(result)
        if let rate = json["rates"]["USD"].double {
          fulfill(rate)
        }
        else {
          reject(response.error!)
        }
      }
    }
  }
}

func getExchangeRate(symbol: String, pair: String) -> Promise<Double> {
  let exchangeURL = URL(string: "https://ratesapi.io/api/latest?symbols=\(symbol)&base=\(pair)")!
  
  return Promise { fulfill, reject in
    Alamofire.request(exchangeURL).responseJSON { (response) in
      if  let result = response.result.value {
        let json = JSON(result)
        if let rate = json["rates"][symbol].double {
          fulfill(rate)
        }
        else {
          reject(response.error!)
        }
      }
    }
  }
}
