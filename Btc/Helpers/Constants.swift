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
    static let countryList = [("australia", "AUD", "en_AU", "Australian Dollar"),
                              ("brazil", "BRL", "pt_BR", "Brazilian real"),
                              ("canada", "CAD", "en_CA", "Canadian Dollar"),
                              ("switzerland", "CHF", "fr_CH", "Swiss Franc"),
                              ("chile", "CLP", "es_CL", "Chilean Peso"),
                              ("china", "CNY", "ii_CN", "Chinese Yuan"),
                              ("czech", "CZK", "cs", "Czech Koruna"),
                              ("denmark", "DKK", "da_DK", "Danish Krone"),
                              ("eu", "EUR", "nl_NL", "Euro"),
                              ("uk", "GBP", "en_GB", "British Pound"),
                              ("hongkong", "HKD", "en_HK", "Hong Kong Dollar"),
                              ("hungary", "HUF", "hu_HU", "Hungarian Forint"),
                              ("indonesia", "IDR", "id_ID", "Indonesian Rupiah"),
                              ("israel", "ILS", "he_IL", "Israeili New Shekel"),
                              ("india", "INR", "en_IN", "Indian Rupee"),
                              ("japan", "JPY", "ja_JP", "Japanese Yen"),
                              ("korea", "KRW", "ko_KR", "Korean Won"),
                              ("mexico", "MXN", "es_MX", "Mexican Peso"),
                              ("malaysia", "MYR", "ms_MY", "Malaysian Ringgit"),
                              ("norway", "NOK", "nn_NO", "Norwegian Kroner"),
                              ("newzealand", "NZD", "en_NZ", "New Zealand Dollar"),
                              ("philippines", "PHP", "fil_PH", "Philippine Peso"),
                              ("pakistan", "PKR", "ur_PK", "Pakistan Rupee"),
                              ("poland", "PLN", "pl_PL", "Polish Zloty"),
                              ("russia", "RUB", "ru_RU", "Russian Rouble"),
                              ("sweden", "SEK", "sv_SE", "Swedish Krona"),
                              ("singapore", "SGD", "en_SG", "Singapore Dollar"),
                              ("thailand", "THB", "th_TH", "Thai Baht"),
                              ("turkey", "TRY", "tr_TR", "Turkish Lira"),
                              ("taiwan", "TWD", "zh_Hant_TW", "Taiwan Dollar"),
                              ("usa", "USD", "en_US", "US Dollar"),
                              ("southafrica", "ZAR", "en_ZA", "South African Rand")]
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
