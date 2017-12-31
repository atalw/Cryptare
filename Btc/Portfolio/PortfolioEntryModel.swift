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
    var coinAmount: Double!
    var cost: Double!
    var dateOfPurchase: Date!
    var currentCoinPrice: Double!
    var currentValue: Double!
    var percentageChange: Double!
    var priceChange: Double!
    
    let dateFormatter = DateFormatter()
    
    init(coin: String, type: String, coinAmount: Double, dateOfPurchase: Date!, cost: Double?, currentCoinPrice: Double!, delegate: PortfolioEntryDelegate) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.delegate = delegate
        
        self.coin = coin
        self.type = type
        self.coinAmount = coinAmount
        self.dateOfPurchase = dateOfPurchase
        self.cost = cost
        self.currentCoinPrice = currentCoinPrice
        self.currentValue = currentCoinPrice * coinAmount
        self.calculateChange()
        self.delegate?.dataLoaded(portfolioEntry: self)
        
    }
    
    func calculateChange() {
        let change = currentValue - cost
        let percentageChange = (change / cost) * 100
        let roundedPercentage = Double(round(100*percentageChange)/100)
        self.priceChange = change
        self.percentageChange = roundedPercentage
        print(change)
    }
}
