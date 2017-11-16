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
    
    var amountOfBitcoin: Double!
    var cost: Double!
    var dateOfPurchase: Date!
    var currentBtcPrice: Double!
    var currentValue: Double!
    var percentageChange: Double!
    var priceChange: Double!
    
    let dateFormatter = DateFormatter()
    
    init(amountOfBitcoin: Double, dateOfPurchase: Date!, currentBtcPrice: Double!, delegate: PortfolioEntryDelegate) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.delegate = delegate
        self.amountOfBitcoin = amountOfBitcoin
        self.dateOfPurchase = dateOfPurchase
        self.currentBtcPrice = currentBtcPrice
        self.currentValue = currentBtcPrice * amountOfBitcoin
        calculateCostFromDate { (success) -> Void in
            self.calculateChange()
            print("done")
            self.delegate?.dataLoaded(portfolioEntry: self)
        }
    }
    
    func calculateCostFromDate(completion: @escaping (_ success: Bool) -> Void) {
        let dateOfPurchaseString = dateFormatter.string(from: dateOfPurchase)
        let todaysDateString = dateFormatter.string(from: Date())
        
//        print(dateOfPurchaseString)
//        print(todaysDateString)
        
        if dateOfPurchaseString == todaysDateString {
            print("here")
            cost = currentBtcPrice * amountOfBitcoin
            print(cost)
            completion(true)
        }
        else {
            let url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(dateOfPurchaseString)&end=\(dateOfPurchaseString)")!
            
            Alamofire.request(url).responseJSON(completionHandler: { response in
                
                let json = JSON(data: response.data!)
                if let price = json["bpi"][dateOfPurchaseString].double {
                    self.cost = price * self.amountOfBitcoin
                    completion(true)
                }
            })
        }
        
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
