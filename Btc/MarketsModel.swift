//
//  MarketsModel.swift
//  Btc
//
//  Created by Akshit Talwar on 04/10/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation

class Market {
    var title: String!
    var buyPrice: Double!
    var sellPrice: Double!
    
    init(title: String, buyPrice: Double, sellPrice: Double) {
        self.title = title
        self.sellPrice = sellPrice
        self.buyPrice = buyPrice
    }
}
