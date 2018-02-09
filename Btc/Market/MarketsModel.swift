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
    var siteLink: URL!
    var buyPrice: Double!
    var sellPrice: Double!
    var lastPrice: Double?
    var description: String!
    var links: [String] = []
    
    init(title: String, siteLink: URL!, buyPrice: Double, sellPrice: Double, description: String, links: [String]) {
        self.title = title
        self.siteLink = siteLink
        self.sellPrice = sellPrice
        self.buyPrice = buyPrice
        self.description = description
        self.links = links
    }
}
