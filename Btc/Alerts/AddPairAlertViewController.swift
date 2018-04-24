//
//  AddPairAlertViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase

class AddPairAlertViewController: UIViewController {
  
  var tradingPair: (String, String)?
  var exchange: (String, String)?
  var exchangePrice: Double?
  
  var thresholdPrice: Double = 0.0
  var isAbove: Bool = true
  
  @IBOutlet weak var addAlertButton: UIButton!
  
  @IBAction func addAlertButtonTapped(_ sender: Any) {
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    addAlertButton.isEnabled = false
  }
  
  func updateAddAlertButton() {
    if tradingPair?.0 != "None" && exchange?.0 != "None" && thresholdPrice > 0 {
      addAlertButton.isEnabled = true
    }
    else {
      addAlertButton.isEnabled = false
    }
  }
  
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVc = segue.destination
    if let addAlertTableVc = destinationVc as? AddPairAlertTableViewController {
      
      if tradingPair == nil {
        tradingPair = ("None", "none")
      }
      
      if exchange == nil {
        exchange = ("None", "none")
      }
      
      addAlertTableVc.parentController = self
      addAlertTableVc.tradingPair = self.tradingPair
      addAlertTableVc.exchange = self.exchange
      addAlertTableVc.exchangePrice = self.exchangePrice
    }
   }
  
}

class AddPairAlertTableViewController: UITableViewController {
  
  var parentController: AddPairAlertViewController!
  
  var tradingPair: (String, String)!
  var exchange: (String, String)!

  // tradingPairs: [(coin, currency)]
  var tradingPairs: [(String, String)] = []
  // markets: [currency: [(marketName, dbTableTitle)]
  var allMarkets: [String: [String: String]] = [:]
  var currentTradingPairMarkets: [String: String] = [:]

  var exchangePrice: Double!
  
  var coinReference: DatabaseReference!
  var exchangeReference: DatabaseReference!
  
  @IBOutlet weak var tradingPairLabel: UILabel! {
    didSet {
      tradingPairLabel.adjustsFontSizeToFitWidth = true
      tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
      tradingPairLabel.text = "\(tradingPair.0)/\(tradingPair.1)"
    }
  }
  @IBOutlet weak var exchangeLabel: UILabel! {
    didSet {
      exchangeLabel.adjustsFontSizeToFitWidth = true
      exchangeLabel.theme_textColor = GlobalPicker.viewTextColor
      exchangeLabel.text = "\(exchange.0)"
    }
  }
  @IBOutlet weak var thresholdPriceLabel: UITextField! {
    didSet {
      thresholdPriceLabel.adjustsFontSizeToFitWidth = true
      thresholdPriceLabel.theme_textColor = GlobalPicker.viewTextColor
      thresholdPriceLabel.addDoneCancelToolbar()
      thresholdPriceLabel.delegate = self
    }
  }
  @IBOutlet weak var isAboveSwitch: UISwitch! {
    didSet {
      isAboveSwitch.setOn(true, animated: true)
    }
  }
  
  @IBOutlet weak var tradingPairDescLabel: UILabel! {
    didSet {
      tradingPairDescLabel.adjustsFontSizeToFitWidth = true
      tradingPairDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var exchangeDescLabel: UILabel! {
    didSet {
      exchangeDescLabel.adjustsFontSizeToFitWidth = true
      exchangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var thresholdPriceDescLabel: UILabel! {
    didSet {
      thresholdPriceDescLabel.adjustsFontSizeToFitWidth = true
      thresholdPriceDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var aboveDescLabel: UILabel! {
    didSet {
      aboveDescLabel.adjustsFontSizeToFitWidth = true
      aboveDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  @IBAction func isAboveSwitchTapped(_ sender: Any) {
    parentController.isAbove = isAboveSwitch.isOn
    
    if isAboveSwitch.isOn {
      if parentController.thresholdPrice < exchangePrice {
        // show alert
        showThresholdPriceAlert(isPriceLower: true)
      }
    }
    else {
      if parentController.thresholdPrice > exchangePrice {
        // show alert
        showThresholdPriceAlert(isPriceLower: false)
      }
    }
    
  }
  
  // set threshold price and above switch values in parent controller
  // enable add alert button
  // implement save to UserD and Firebase
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    exchangeReference = Database.database().reference()
    
    if tradingPair.0 != "None" {
      let coin = tradingPair.0
      coinReference = Database.database().reference().child(coin)
      
      coinReference.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
        if let dict = snapshot.value as? [String : AnyObject] {
          for (title, data) in dict {
            if title != "name" && title != "rank" {
              self.tradingPairs.append((coin, title))
              self.allMarkets[title] = [:]
              if let markets = data["markets"] as? [String: String] {
                //                            print(markets)
                self.allMarkets[title] = markets
              }
              self.allMarkets[title]!["None"] = "none"
            }
          }
          self.updateLabels()
        }
      })
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    coinReference.removeAllObservers()
    exchangeReference.removeAllObservers()
  }
    
  func updateLabels() {
    if let markets = allMarkets[tradingPair.1] as? [String: String] {
      self.currentTradingPairMarkets = markets
//      self.exchangePrice = ("None", "none")
//      self.currentExchangeLabel.text = currentExchange.0
    }
  }
  
  func updateCurrentTradingPair(pair: (String, String)) {
    self.tradingPair = pair
    self.tradingPairLabel.text = "\(pair.0)-\(pair.1)"
    
    if let markets = allMarkets[pair.1] {
      currentTradingPairMarkets = markets
      self.exchange = ("None", "none")
      self.exchangeLabel.text = exchange.0
    }
    
    self.parentController.tradingPair = self.tradingPair
    self.parentController.exchange = exchange
  }
  
  func updateCurrentExchange(exchange: (String, String)) {
    self.exchange = exchange
    self.exchangeLabel.text = exchange.0
    
    self.parentController.exchange = exchange
    
    if exchange.0 != "None" {
      updateThresholdPriceTextfield(exchange: exchange)
    }
    else {
      parentController.thresholdPrice = 0.0
      self.thresholdPriceLabel.text = ""
    }
  }
  
  func updateThresholdPriceTextfield(exchange: (String, String)) {
    exchangeReference.child(exchange.1).observe(.value, with: {(snapshot) -> Void in
      if let dict = snapshot.value as? [String: AnyObject] {
        let buyPrice = dict["buy_price"] as! Double
        self.exchangePrice = buyPrice
        self.thresholdPriceLabel.text = "\(buyPrice)"
        self.parentController.thresholdPrice = buyPrice
      }
    })
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    cell.selectionStyle = .none
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  func showThresholdPriceAlert(isPriceLower: Bool) {
    var dialogMessage: UIAlertController!
    if isPriceLower {
      dialogMessage = UIAlertController(title: "Confirm", message: "The threshold price you set is lower than the current market price. The alert will trigger when the current price goes below  the threshold price.", preferredStyle: .alert)
    }
    else {
      dialogMessage = UIAlertController(title: "Confirm", message: "The threshold price you set is higher than the current market price. The alert will trigger when the current price goes above the threshold price.", preferredStyle: .alert)
    }
    
    
    let yesAction = UIAlertAction(title: "Ok", style: .default, handler: { action -> Void in
      print("yes tapped")
      self.isAboveSwitch.setOn(!self.isAboveSwitch.isOn, animated: true)
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action -> Void in
      print("no tapped")
      self.thresholdPriceLabel.text = ""
      self.parentController.thresholdPrice = 0
    })
    
    dialogMessage.addAction(yesAction)
    dialogMessage.addAction(cancelAction)
    
    self.present(dialogMessage, animated: true, completion: nil)
  }
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let destinationVc = segue.destination as? TradingPairTableViewController {
      destinationVc.parentController = self
      destinationVc.tradingPairs = self.tradingPairs
    }
    else if let destinationVc = segue.destination as? AvailableExchangesTableViewController {
      destinationVc.parentController = self
      destinationVc.markets = self.currentTradingPairMarkets
    }
   }
  
  
}

extension AddPairAlertTableViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {}
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == self.thresholdPriceLabel {
      if let text = textField.text {
        if let thresholdPrice = Double(text) {
          print(exchangePrice)
          if exchangePrice != nil {
            if thresholdPrice > exchangePrice {
              if isAboveSwitch.isOn {
                parentController.thresholdPrice = thresholdPrice
              }
              else {
                showThresholdPriceAlert(isPriceLower: false)
              }
            }
            else {
              if isAboveSwitch.isOn {
                showThresholdPriceAlert(isPriceLower: true)
              }
              else {
                parentController.thresholdPrice = thresholdPrice
              }
            }
          }
        }
        else {
          parentController.thresholdPrice = 0.0
        }
      }
    }
    parentController.updateAddAlertButton()
  }
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return true;
  }
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return true;
  }
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return true;
  }
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  
}
