//
//  PortfolioModel.swift
//  Btc
//
//  Created by Akshit Talwar on 13/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PortfolioEntryModel {
    
    var amountOfBitcoin: Double!
    var cost: Double!
    var dateOfPurchase: Date!
    
    var currentValue: Double!
    var isProfit: Bool!
    var percentageChange: Double!
    var priceChange: Double!
    
    let dateFormatter = DateFormatter()
    
    init(amountOfBitcoin: Double, dateOfPurchase: Date!, currentBtcPrice: Double!) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        self.amountOfBitcoin = amountOfBitcoin
        self.dateOfPurchase = dateOfPurchase
        self.currentValue = currentBtcPrice * amountOfBitcoin
        
        
    }
    
    func calculateCostFromDate(completion: @escaping (_ success: Bool) -> Void) {
        let dateOfPurchaseString = dateFormatter.string(from: dateOfPurchase)
        
        let url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(dateOfPurchaseString)&end=\(dateOfPurchaseString)")!
        
        Alamofire.request(url).responseJSON(completionHandler: { response in

            let json = JSON(data: response.data!)
            if let price = json["bpi"][dateOfPurchaseString].double {
                self.cost = price * self.amountOfBitcoin
                completion(true)
            }
        })
    }
    
    func calculateChange() {
        
        print(cost)
        print(currentValue)
        
        if cost > currentValue {
            isProfit = false
        }
        else {
            isProfit = true
        }
        let change = currentValue - cost
        let percentageChange = (change / currentValue) * 100
        let roundedPercentage = Double(round(100*percentageChange)/100)
        
        print(change)
        print(percentageChange)
        self.priceChange = change
        self.percentageChange = roundedPercentage
        
    }
}
