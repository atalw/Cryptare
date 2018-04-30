//
//  FirebaseService.swift
//  Cryptare
//
//  Created by Akshit Talwar on 17/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import SwiftyUserDefaults

class FirebaseService: NSObject {
  
  // cant create IAPService object
  private override init() { super.init(); get_uid() }
  
  // use singleton
  static let shared = FirebaseService()
  
  var uid: String?
  
  func get_uid() {
    if Auth.auth().currentUser?.uid != nil {
      self.uid = Auth.auth().currentUser?.uid
    }
  }
  
  func updatePortfolioNames() {
    // update on firebase
    if let uid = uid {
      let portfolioNamesRef = Database.database().reference().child("portfolios").child(uid).child("Names")
      portfolioNamesRef.setValue(Defaults[.portfolioNames]) { (err, ref) in
        if err != nil {
          print(err!, "Names update")
        }
      }
    }
  }
  
  func updateCryptoPortfolioName() {
    if let uid = uid {
      let cryptoDataRef = Database.database().reference().child("portfolios").child(uid).child("CryptoData")
      cryptoDataRef.setValue(Defaults[.cryptoPortfolioData]) { (err, ref) in
        if err != nil {
          print(err!, "Crypto update")
        }
      }
    }
  }
  
  func updateFiatPortfolioName() {
    if let uid = uid {
      let fiatDataRef = Database.database().reference().child("portfolios").child(uid).child("FiatData")
      fiatDataRef.setValue(Defaults[.fiatPortfolioData]) { (err, ref) in
        if err != nil {
          print(err!, "Fiat update")
        }
      }
    }
  }
  
  func updatePortfolioData(databaseTitle: String, data: [String: Any]) {
    if let uid = uid {
      let portfolioRef = Database.database().reference().child("portfolios").child(uid).child(databaseTitle)
      portfolioRef.updateChildValues(data) { (err, ref) in
        if err != nil {
          print(err!, "\(databaseTitle) update")
        }
      }
    }
  }
  
  func deletePortfolioData(databaseTitle: String, data: [String: Any]) {
    if let uid = uid {
      let portfolioRef = Database.database().reference().child("portfolios").child(uid).child(databaseTitle)
      portfolioRef.setValue(data) { (err, ref) in
        if err != nil {
          print(err!, "\(databaseTitle) update")
        }
      }
    }
  }
  
  func update_coin_alerts(data: [String: Any]) {
    Defaults[.allCoinAlerts] = data

    if let uid = uid {
      let coinAlertRef = Database.database().reference().child("coin_alerts").child(uid)
      coinAlertRef.setValue(data) { (err, ref) in
        if err != nil {
          print(err!, "coin alert update")
        }
      }
    }
  }
  
  func add_users_coin_alerts(exchangeName: String, tradingPair: (String, String)) {
    var uid: String!
    if let uid = uid {
      let userCoinAlertRef = Database.database().reference().child("coin_alerts_users")
      
      userCoinAlertRef.observeSingleEvent(of: .value) { (snapshot) in
        if var dict = snapshot.value as? [String: [String: [String: [String: Int]]]] {
          if dict[exchangeName] != nil {
            if dict[exchangeName]![tradingPair.0] != nil {
              if dict[exchangeName]![tradingPair.0]![tradingPair.1] != nil {
                if dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] != nil {
                  let count = dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid]!
                  dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] = count + 1
                }
                else {
                  dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] = 1
                }
              }
              else {
                dict[exchangeName]![tradingPair.0]![tradingPair.1] = [uid: 1]
              }
            }
            else {
              dict[exchangeName]![tradingPair.0] = [tradingPair.1: [uid: 1]]
            }
          }
          else {
            dict[exchangeName] = [tradingPair.0: [tradingPair.1: [uid: 1]]]
          }
          
          userCoinAlertRef.setValue(dict) { (err, ref) in
            if err != nil {
              print(err!, "users coin alert update")
            }
          }
        }
      }
    }
  }
  
  func remove_users_coin_alerts(exchangeName: String, tradingPair: (String, String)) {
    var uid: String!
    if let uid = uid {
      let userCoinAlertRef = Database.database().reference().child("coin_alerts_users")
      
      userCoinAlertRef.observeSingleEvent(of: .value) { (snapshot) in
        if var dict = snapshot.value as? [String: [String: [String: [String: Int]]]] {
          if dict[exchangeName] != nil {
            if dict[exchangeName]![tradingPair.0] != nil {
              if dict[exchangeName]![tradingPair.0]![tradingPair.1] != nil {
                if dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] != nil {
                  let count = dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid]!
                  if count == 1 {
                    dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] = nil
                  }
                  else {
                    dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] = count - 1
                  }
                }
                else {
                  dict[exchangeName]![tradingPair.0]![tradingPair.1]![uid] = 1
                }
              }
              else {
                dict[exchangeName]![tradingPair.0]![tradingPair.1] = [uid: 1]
              }
            }
            else {
              dict[exchangeName]![tradingPair.0] = [tradingPair.1: [uid: 1]]
            }
          }
          else {
            dict[exchangeName] = [tradingPair.0: [tradingPair.1: [uid: 1]]]
          }
          
          userCoinAlertRef.setValue(dict) { (err, ref) in
            if err != nil {
              print(err!, "users coin alert update")
            }
          }
        }
      }
    }
  }
}

// Firebase Analytics functions
extension FirebaseService {
  
  func updateScreenName(screenName: String, screenClass: String) {
    Analytics.setScreenName(screenName, screenClass: screenClass)
  }
  
  // Dashboard
  func dashboard_coin_tapped(coin: String) {
    Analytics.logEvent("dashboard_coin_tapped", parameters: [
      "coin": coin as NSString
      ])
  }
  
  func favourite_action_tapped(coin: String, status: String) {
    Analytics.logEvent("favourite_action_tapped", parameters: [
      "coin": coin as NSString,
      "status": status as NSString
      ])
  }
  
  // Coin Markets
  func coin_markets_view_appeared(coin: String, currency: String) {
    Analytics.logEvent("coin_markets_view_appeared", parameters: [
      "coin": coin as NSString,
      "currency": currency as NSString
      ])
  }
  
  func coin_market_button_tapped(name: String) {
    Analytics.logEvent("coin_market_url_tapped", parameters: [
      "exchange": name as NSString
      ])
  }
  
  // Markets
  
  func all_markets_view_appeared() {
    Analytics.logEvent("all_markets_view_appeared", parameters: [:])
  }
  
  func all_markets_trading_pair_tapped(coin: String, pair: String, exchange: String) {
    Analytics.logEvent("all_markets_trading_pair_tapped", parameters: [
      "coin": coin as NSString,
      "pair": pair as NSString,
      "exchange": exchange as NSString
      ])
  }
  
  func all_markets_trading_pair_favourited(coin: String, pair: String, exchange: String) {
    Analytics.logEvent("all_markets_trading_pair_favourited", parameters: [
      "coin": coin as NSString,
      "pair": pair as NSString,
      "exchange": exchange as NSString
      ])
  }
  
  func all_markets_exchange_tapped(exchange: String) {
    Analytics.logEvent("all_markets_exchange_tapped", parameters: [
      "exchange": exchange as NSString
      ])
  }
  
  func all_markets_exchange_favourited(exchange: String) {
    Analytics.logEvent("all_markets_exchange_favourited", parameters: [
      "exchange": exchange as NSString
      ])
  }
  
  // Alerts
  
  func alert_added(coin: String, pair: String, exchange: String) {
    Analytics.logEvent("alert_added", parameters: [
      "coin": coin as NSString,
      "pair": pair as NSString,
      "exchange": exchange as NSString
      ])
  }
  
  // News
  func news_view_appeared(coin: String, country: String) {
    Analytics.logEvent("news_view_appeared", parameters: [
      "coin": coin as NSString,
      "country": country as NSString
      ])
  }
  
  func news_article_tapped(url: String) {
    Analytics.logEvent("market_url_tapped", parameters: [
      "url": url as NSString
      ])
  }
  // Portfolio
  func crypto_transaction_added(coin: String) {
    Analytics.logEvent("crypto_transaction_added", parameters: [
      "coin": coin as NSString
      ])
  }
  
  func fiat_transaction_added(currency: String) {
    Analytics.logEvent("fiat_transaction_added", parameters: [
      "currency": currency as NSString
      ])
  }
  
  func transaction_tradingPair_selected(pair: (String, String)) {
    Analytics.logEvent("transaction_tradingPair_selected", parameters: [
      "quote": pair.0 as NSString,
      "base": pair.1 as NSString
      ])
  }
  
  func transaction_exchange_selected(name: String) {
    Analytics.logEvent("transaction_exchange_selected", parameters: [
      "name": name as NSString,
      ])
  }
  
  // IAP
  func subscription_page_opened() {
    Analytics.logEvent("subscription_page_opened", parameters: nil)
  }
  
  func one_month_subscription_tapped() {
    Analytics.logEvent("one_month_subscription_tapped", parameters: nil)
  }
  
  func one_year_subscription_tapped() {
    Analytics.logEvent("one_year_subscription_tapped", parameters: nil)
  }
  
  func privacy_tapped_from_subscription() {
    Analytics.logEvent("privacy_tapped_from_subscription", parameters: nil)
  }
  
  func tos_tapped_from_subscription() {
    Analytics.logEvent("tos_tapped_from_subscription", parameters: nil)
  }
  
  // Settings
  func view_subscription_page_tapped() {
    Analytics.logEvent("view_subscription_page_tapped", parameters: nil)
  }
  
  func rate_app_tapped() {
    Analytics.logEvent("rate_app_tapped", parameters: nil)
  }
  
  func share_app_tapped() {
    Analytics.logEvent("share_app_tapped", parameters: nil)
  }
  
  func support_tapped() {
    Analytics.logEvent("support_tapped", parameters: nil)
  }
  
  func cryptare_twitter_tapped() {
    Analytics.logEvent("cryptare_twitter_tapped", parameters: nil)
  }
  
  func slack_tapped() {
    Analytics.logEvent("slack_tapped", parameters: nil)
  }
  
  func telegram_tapped() {
    Analytics.logEvent("telegram_tapped", parameters: nil)
  }
  
  func privacy_tapped() {
    Analytics.logEvent("privacy_tapped", parameters: nil)
  }
  
  func tos_tapped() {
    Analytics.logEvent("tos_tapped", parameters: nil)
  }
  
  func currency_selected(currency: String) {
    Analytics.logEvent("currency_selected", parameters: [
      "currency": currency as NSString,
      ])
  }
}
