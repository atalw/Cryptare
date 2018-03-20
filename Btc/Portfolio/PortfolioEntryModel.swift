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
    var time: Date!
    
    var currentCoinPrice: Double!
    var currentValue: Double!
    var percentageChange: Double!
    var priceChange: Double!
    
    
    let dateFormatter = DateFormatter()
    
    init(type: String, coin: String, tradingPair: String, exchange: String, costPerCoin: Double!, amountOfCoins: Double, fees: Double!, date: Date!, time: Date!, currentCoinPrice: Double!,
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
        self.time = time
        
        self.currentCoinPrice = currentCoinPrice
        self.currentValue = currentCoinPrice * amountOfCoins
        self.calculateChange()
        self.exchange = exchange
        
        self.totalCost = costPerCoin * amountOfCoins

        self.delegate?.dataLoaded(portfolioEntry: self)

    }
    
    func calculateChange() {
        let totalCost = costPerCoin * amountOfCoins
        let change = currentValue - totalCost
        let percentageChange = (change / totalCost) * 100
        let roundedPercentage = Double(round(100*percentageChange)/100)
        self.priceChange = change
        self.percentageChange = roundedPercentage
    }
}
