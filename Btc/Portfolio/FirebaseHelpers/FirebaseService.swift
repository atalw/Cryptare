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
  private override init() {}
  
  // use singleton
  static let shared = FirebaseService()
  
  func updatePortfolioNames() {
    // update on firebase
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let portfolioNamesRef = Database.database().reference().child("portfolios").child(uid).child("Names")
      portfolioNamesRef.setValue(Defaults[.portfolioNames]) { (err, ref) in
        if err != nil {
          print(err, "Names update")
        }
      }
    }
  }
  
  func updateCryptoPortfolioName() {
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let cryptoDataRef = Database.database().reference().child("portfolios").child(uid).child("CryptoData")
      cryptoDataRef.setValue(Defaults[.cryptoPortfolioData]) { (err, ref) in
        if err != nil {
          print(err, "Crypto update")
        }
      }
    }
  }
  
  func updateFiatPortfolioName() {
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let fiatDataRef = Database.database().reference().child("portfolios").child(uid).child("FiatData")
      fiatDataRef.setValue(Defaults[.fiatPortfolioData]) { (err, ref) in
        if err != nil {
          print(err, "Fiat update")
        }
      }
    }
  }
  
  func updatePortfolioData(databaseTitle: String, data: [String: Any]) {
    // update on firebase
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let portfolioRef = Database.database().reference().child("portfolios").child(uid).child(databaseTitle)
      portfolioRef.updateChildValues(data) { (err, ref) in
        if err != nil {
          print(err, "\(databaseTitle) update")
        }
      }
    }
  }
  
  func deletePortfolioData(databaseTitle: String, data: [String: Any]) {
    // update on firebase
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let portfolioRef = Database.database().reference().child("portfolios").child(uid).child(databaseTitle)
      portfolioRef.setValue(data) { (err, ref) in
        if err != nil {
          print(err, "\(databaseTitle) update")
        }
      }
    }
  }
  
}

// Firebase Analytics functions
extension FirebaseService {
  
  // Dashboard
  func dashboard_coin_tapped(coin: String) {
    Analytics.logEvent("dashboard_coin_tapped", parameters: [
      "coin": coin as NSString
      ])
  }
  
  func favourite_coin_tapped(coin: String, status: String) {
    Analytics.logEvent("favourite_coin_tapped", parameters: [
      "coin": coin as NSString,
      "status": status as NSString
      ])
  }
  
  // Markets
  func market_view_appeared(coin: String, currency: String) {
    Analytics.logEvent("market_view_appeared", parameters: [
      "coin": coin as NSString,
      "currency": currency as NSString
      ])
  }
  
  func market_button_tapped(name: String) {
    Analytics.logEvent("market_url_tapped", parameters: [
      "market": name as NSString
      ])
  }
  
  // News
  func news_view_appeared(coin: String, country: String) {
    Analytics.logEvent("news_view_appeared", parameters: [
      "coin": coin as NSString,
      "country": country as NSString
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
}
