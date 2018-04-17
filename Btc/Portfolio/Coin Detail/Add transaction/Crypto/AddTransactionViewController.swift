//
//  AddTransactionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase

class AddTransactionViewController: UIViewController {
  
  var parentController: CryptoPortfolioViewController!
  var portfolioName: String!
  
  let dateFormatter = DateFormatter()
  
  let greenColour = UIColor.init(hex: "2ECC71")
  let redColour = UIColor.init(hex: "E74C3C")
  let navyBlueColour = UIColor.init(hex: "46637F")
  
  var transactionType: String!
  
  var coin: String!
  var currencies: [String] = []
  
  var currentTradingPair: (String, String)!
  var currentExchange: (String, String)!
  var costPerCoin: Double!
  var amountOfCoins: Double!
  var fees: Double!
  var date: Date!
  var deductFromHoldings: Bool!
  
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var totalTransactionCostLabel: UILabel! {
    didSet {
      totalTransactionCostLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var addTransactionButton: UIButton! {
    didSet {
      
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    portfolioName = parentController.portfolioName
    
    addTransactionButton.setBackgroundColor(color: UIColor.darkGray, forState: .disabled)
    
    addTransactionButton.setTitleColor(UIColor.white, for: .normal)
    addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
    
    addTransactionButton.isEnabled = false
    
    if transactionType == "buy" {
      addTransactionButton.setTitle("Add Buy Transaction", for: .normal)
      addTransactionButton.setBackgroundColor(color: greenColour, forState: .normal)
      
    }
    else if transactionType == "sell" {
      addTransactionButton.setTitle("Add Sell Transaction", for: .normal)
      addTransactionButton.setBackgroundColor(color: redColour, forState: .normal)
      
    }
    
    for (country, symbol, locale, name) in GlobalValues.countryList {
      currencies.append(symbol)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func updateAddTransactionButtonStatus() {
    
    if costPerCoin != nil && amountOfCoins != nil && fees != nil {
      let totalCost = (costPerCoin * amountOfCoins) + fees
      
      if currentTradingPair.1 == "BTC" {
        totalTransactionCostLabel.text = "Total cost of transaction is \(totalCost.asBtcCurrency)"
        
      }
      else if currentTradingPair.1 == "ETH" {
        totalTransactionCostLabel.text = "Total cost of transaction is \(totalCost.asEthCurrency)"
        
      }
      else {
        totalTransactionCostLabel.text = "Total cost of transaction is \(totalCost.asSelectedCurrency(currency: currentTradingPair.1))"
      }
    }
    else {
      if currentTradingPair.1 == "BTC" {
        totalTransactionCostLabel.text = "Total cost of transaction is \(0.0.asBtcCurrency)"
      }
      else if currentTradingPair.1 == "ETH" {
        totalTransactionCostLabel.text = "Total cost of transaction is \(0.0.asEthCurrency)"
      }
      else {
        totalTransactionCostLabel.text = "Total cost of transaction is \(0.0.asSelectedCurrency(currency: currentTradingPair.1))"
      }
    }
    
    if currentTradingPair != nil && currentExchange != nil &&
      costPerCoin != nil && amountOfCoins != nil &&
      fees != nil && date != nil {
      addTransactionButton.isEnabled = true
    }
    else {
      addTransactionButton.isEnabled = false
    }
  }
  
  @IBAction func addTransactionButtonTapped(_ sender: Any) {
    dateFormatter.dateFormat =  "yyyy-MM-dd hh:mm a"

    let tradingPair = currentTradingPair.1
    let amount = costPerCoin*amountOfCoins
    let totalCost = amount - fees
    let dateString = dateFormatter.string(from: date)
    
    if currencies.contains(tradingPair) {
      let data: [String: Any] = ["type": transactionType,
                                 "coin": coin,
                                 "tradingPair": tradingPair,
                                 "exchange": currentExchange.0,
                                 "costPerCoin": costPerCoin,
                                 "amountOfCoins": amountOfCoins,
                                 "fees": fees,
                                 "totalCost": totalCost,
                                 "date": dateString]
      
      parentController.portfolioTableController.addPortfolioEntry(portfolioEntry: data)
      
      if deductFromHoldings {
        var type: String!
        if transactionType == "buy" {
          type = "withdraw"
        }
        else {
          type = "deposit"
        }
        addFiatTransaction(currency: tradingPair, type: type, exchange: currentExchange.0, amount: amount, fees: fees, date: dateString)
      }
    }
    else {
      Database.database().reference().child(tradingPair)
        .observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String : AnyObject] {
            let price = dict[GlobalValues.currency!]!["price"] as! Double
            let totalCost = ((self.costPerCoin * self.amountOfCoins) - self.fees) * price
            let data: [String: Any] = ["type": self.transactionType,
                                       "coin": self.coin,
                                       "tradingPair": tradingPair,
                                       "exchange": self.currentExchange.0,
                                       "costPerCoin": self.costPerCoin,
                                       "amountOfCoins": self.amountOfCoins,
                                       "fees": self.fees,
                                       "totalCost": totalCost,
                                       "fiat": GlobalValues.currency!,
                                       "date": dateString]
            
            self.parentController.portfolioTableController.addPortfolioEntry(portfolioEntry: data)
            
            
            if self.deductFromHoldings {
              self.addCryptoTransaction(tradingPair: tradingPair, exchangePrice: price)
            }
          }
        })
    }
    
    self.navigationController?.popViewController(animated: true)
    
  }
  
  func addFiatTransaction(currency: String, type: String, exchange: String, amount: Double, fees: Double, date: String) {
    
    let transaction: [String : Any] = ["type": type,
                                       "exchange": exchange,
                                       "amount": amount,
                                       "fees": fees,
                                       "date": date]
    
    var allData = Defaults[.fiatPortfolioData]
    if allData[portfolioName] == nil {
      allData[portfolioName] = [:]
    }
    if var currentPortfolioData = allData[portfolioName] as? [String: [[String: Any]] ] {
      var data: [String: [[String: Any]] ] = [:]
      if currentPortfolioData[currency] == nil {
        currentPortfolioData[currency] = []
      }
      for (fiat, transactions) in currentPortfolioData {
        data[fiat] = transactions
        if fiat == currency {
          data[fiat]?.append(transaction)
        }
      }
      allData[portfolioName] = data
      Defaults[.fiatPortfolioData] = allData
      parentController.parentController.loadAllPortfolios(cryptoPortfolioData: nil, fiatPortfolioData: data)
    }
  }
  
  func addCryptoTransaction(tradingPair: String, exchangePrice: Double) {
    var type: String!
    if self.transactionType == "buy" {
      type = "cryptoSell"
    }
    else {
      type = "cryptoBuy"
    }
    let amountOfCoins = self.amountOfCoins*self.costPerCoin
    let totalCostFiat = (amountOfCoins-self.fees) * exchangePrice
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
    let dateString = dateFormatter.string(from: date)
    
    let cryptoData: [String: Any] = ["type": type,
                                     "tradingPair": self.coin,
                                     "exchange": self.currentExchange.0,
                                     "costPerCoin": self.costPerCoin,
                                     "amountOfCoins": amountOfCoins,
                                     "fees": self.fees,
                                     "date": dateString,
                                     "fiatPrice": exchangePrice,
                                     "fiat": GlobalValues.currency!]
    self.parentController.portfolioTableController
      .savePortfolioEntry(coin: tradingPair, transaction: cryptoData)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let destinationVC = segue.destination
    if let addTransactionController = destinationVC as? AddTransactionTableViewController {
      addTransactionController.parentController = self
      addTransactionController.transactionType = self.transactionType
      addTransactionController.coin = self.coin
    }
  }
}
