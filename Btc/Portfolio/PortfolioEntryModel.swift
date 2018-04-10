//
//  PortfolioModel.swift
//  Btc
//
//  Created by Akshit Talwar on 13/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation
import Firebase

class PortfolioEntryModel {
    
    weak var delegate: PortfolioEntryDelegate?
    
    var coin: String!
    
    var type: String!
    var tradingPair: String!

    var exchange: String!

    var costPerCoin: Double!
    var amountOfCoins: Double!
    var fees: Double!
    
    var totalCost: Double!
    
    var date: Date!
    
    var currentCoinPrice: Double!
    var currentValue: Double!
    var percentageChange: Double!
    var priceChange: Double!
    
    
    let dateFormatter = DateFormatter()
    
    init(type: String, coin: String, tradingPair: String, exchange: String, costPerCoin: Double!, amountOfCoins: Double, fees: Double!, date: Date!, currentCoinPrice: Double!,
         delegate: PortfolioEntryDelegate) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.delegate = delegate
        
        self.type = type

        self.coin = coin
        self.tradingPair = tradingPair
        
        self.costPerCoin = costPerCoin
        self.amountOfCoins = amountOfCoins
        self.fees = fees
        
        self.date = date
        
        self.currentCoinPrice = currentCoinPrice
        
        self.currentValue = currentCoinPrice * amountOfCoins
        self.totalCost = (costPerCoin * amountOfCoins) - fees
        
        self.exchange = exchange
        
        var crypto = tradingPair
        if type == "cryptoBuy" || type == "cryptoSell" {
            crypto = coin
        }

        if crypto == "BTC" || crypto == "ETH" {
            Database.database().reference().child(crypto).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let price = dict[GlobalValues.currency!]!["price"] as! Double
                    
                    if self.type == "cryptoBuy" || self.type == "cryptoSell" {
                        self.totalCost = (self.amountOfCoins - self.fees) * price
                    }
                    else {
                        self.totalCost = self.totalCost * price
                    }
                    self.calculateChange()
                    self.delegate?.dataLoaded(portfolioEntry: self)
                }
            })

//            Database.database().reference().child(coin).child(tradingPair).child("markets").child(exchange).observeSingleEvent(of: .value, with: {(snapshot) in
//                if let dict = snapshot.value as? [String: AnyObject] {
//                    print(dict)
////                    let price = dict[GlobalValues.currency!]!["price"] as! Double
////                    self.totalCost = self.totalCost * price
////                    self.calculateChange()
////                    self.delegate?.dataLoaded(portfolioEntry: self)
//                }
//            })
        }
        else {
            self.calculateChange()
            self.delegate?.dataLoaded(portfolioEntry: self)
        }
    }
    
    func calculateChange() {
        let change = currentValue - totalCost
        let percentageChange = (change / totalCost) * 100
        let roundedPercentage = Double(round(100*percentageChange)/100)
        self.priceChange = change
        self.percentageChange = roundedPercentage
    }
}
