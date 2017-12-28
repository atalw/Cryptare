//
//  Constants.swift
//  Btc
//
//  Created by Akshit Talwar on 21/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation

public struct GlobalValues {
    static var currency: String!
    static var currentBtcPrice: Double!
    static var currentBtcPriceString: String!
    static var coins: [(String, String)] = []
}

public struct ChartSettings {
    static var chartMode: String! = UserDefaults.standard.string(forKey: "chartMode")
    
    static var xAxis: Bool! = UserDefaults.standard.bool(forKey: "xAxis")
    static var xAxisGridLinesEnabled: Bool! = UserDefaults.standard.bool(forKey: "xAxisGridLinesEnabled")
    
    static var yAxis: Bool! = UserDefaults.standard.bool(forKey: "yAxis")
    static var yAxisGridLinesEnabled: Bool! = UserDefaults.standard.bool(forKey: "yAxisGridLinesEnabled")
}

public struct ChartSettingsDefault {
    static let chartMode: String! = "smooth"
    
    static let xAxis: Bool! = true
    static let xAxisGridLinesEnabled: Bool! = true
    
    static let yAxis: Bool! = true
    static let yAxisGridLinesEnabled: Bool! = true
}
