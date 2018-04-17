//
//  FirebaseService.swift
//  Cryptare
//
//  Created by Akshit Talwar on 17/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
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
