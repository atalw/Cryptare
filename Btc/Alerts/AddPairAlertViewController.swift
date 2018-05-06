//
//  AddPairAlertViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class AddPairAlertViewController: UIViewController {
  
  var parentController: UIViewController?
  
  var tradingPair: (String, String)?
  var exchange: (String, String)?
  var exchangePrice: Double?
  
  var thresholdPrice: Double = 0.0
  var isAbove: Bool = true
  
  
  @IBOutlet weak var lockAlertsView: UIView! {
    didSet {
      let subscriptionPurchased = Defaults[.subscriptionPurchased]
      let numberOfCoinAlerts = Defaults[.numberOfCoinAlerts]
      #if DEBUG
      lockAlertsView.isHidden = true
      #else
      if numberOfCoinAlerts < 3 {
        lockAlertsView.isHidden = true
      }
      else {
        if subscriptionPurchased {
          lockAlertsView.isHidden = true
        }
        else {
          lockAlertsView.isHidden = false
        }
      }
      #endif
      
    }
  }
  
  @IBOutlet weak var addAlertButton: UIButton! {
    didSet {
      addAlertButton.theme_backgroundColor = GlobalPicker.addCoinButton
      addAlertButton.setBackgroundColor(color: UIColor.darkGray, forState: .disabled)
      
      addAlertButton.setTitleColor(UIColor.white, for: .normal)
      addAlertButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
  }
  
  @IBAction func addAlertButtonTapped(_ sender: Any) {
    if tradingPair != nil && exchange != nil {
      if tradingPair!.0 != "None" && exchange!.0 != "None" && thresholdPrice > 0 {
        saveAlert()
        self.navigationController?.popViewController(animated: true)
      }
      else {
        addAlertButton.isEnabled = false
      }
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Add Alert"
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    if #available(iOS 11.0, *) {
      self.navigationController?.navigationItem.largeTitleDisplayMode = .never
    } else {
      // Fallback on earlier versions
    }
    
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
  
  func saveAlert() {
    var coinAlerts = Defaults[.allCoinAlerts]
    
    if tradingPair != nil && exchange != nil {
      if tradingPair!.0 != "None" && exchange!.0 != "None" {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, YYYY"
        let dateString = dateFormatter.string(from: Date())
        let arrayDataEntry: [String: Any] = ["thresholdPrice": thresholdPrice,
                                             "isAbove": isAbove,
                                             "isActive": true,
                                             "databaseTitle": exchange!.1,
                                             "date": dateString,
                                             "type": "single"]
        
        if var exchangeData = coinAlerts[exchange!.0] as? [String: Any] {
          if var coinData = exchangeData[tradingPair!.0] as? [String: Any] {
            if var pairData = coinData[tradingPair!.1] as? [[String: Any]] {
              pairData.append(arrayDataEntry)
              coinData[tradingPair!.1] = pairData
              exchangeData[tradingPair!.0] = coinData
              coinAlerts[exchange!.0] = exchangeData
            }
            else {
              coinData[tradingPair!.1] = [arrayDataEntry]
              exchangeData[tradingPair!.0] = coinData
              coinAlerts[exchange!.0] = exchangeData
            }
          }
          else {
            exchangeData[tradingPair!.0] = [tradingPair!.1: [arrayDataEntry]]
            coinAlerts[exchange!.0] = exchangeData
          }
        }
        else {
          coinAlerts[exchange!.0] = [tradingPair!.0: [tradingPair!.1: [arrayDataEntry]]]
        }
        
        
        FirebaseService.shared.update_coin_alerts(data: coinAlerts)
        FirebaseService.shared.add_users_coin_alerts(exchangeName: exchange!.0, tradingPair: tradingPair!)
        
        FirebaseService.shared.alert_added(coin: tradingPair!.0, pair: tradingPair!.1, exchange: exchange!.0)
        
        if let pairDetailContainerVc = parentController as? PairAlertViewController {
          pairDetailContainerVc.loadAlertsFromDefaults()
        }
      }
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
  
  var tradingPair: (String, String)! {
    didSet {
      parentController.tradingPair = tradingPair
    }
  }
  var exchange: (String, String)! {
    didSet {
      parentController.exchange = exchange
    }
  }
  
  // tradingPairs: [(coin, currency)]
  var tradingPairs: [(String, String)] = []
  // markets: [currency: [(marketName, dbTableTitle)]
  var allMarkets: [String: [String: String]] = [:]
  var currentTradingPairMarkets: [String: String] = [:]
  
  var exchangePrice: Double!
  var thresholdPrice: Double! {
    didSet {
      self.parentController.thresholdPrice = thresholdPrice
    }
  }
  
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
      aboveDescLabel.theme_textColor = GlobalPicker.viewTextColor
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
    
    print(exchange, tradingPair)
    
    if exchange.0 != "None" || exchange != nil {
      updateThresholdPriceTextfield(exchange: exchange)
    }
    
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if parentController.lockAlertsView.isHidden {
      if tradingPair.0 == "None" {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddCoinTableViewController") as! AddCoinTableViewController
        controller.parentController = self
        self.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if coinReference != nil {
      coinReference.removeAllObservers()
    }
    
    exchangeReference.removeAllObservers()
  }
  
  func getTradingPairs(coin: String) {
    let databaseRef = Database.database().reference().child(coin)
    
    databaseRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
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
        self.tradingPair = self.tradingPairs.first
        self.updateLabels()
      }
    })
  }
  
  func updateLabels() {
    if let pair = tradingPair {
      self.tradingPairLabel.text = "\(pair.0)/\(pair.1)"
    }
    
    if let markets = allMarkets[tradingPair.1] {
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
        self.thresholdPrice = buyPrice
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
      self.isAboveSwitch.setOn(!self.isAboveSwitch.isOn, animated: true)
      self.parentController.isAbove = self.isAboveSwitch.isOn
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action -> Void in
      self.thresholdPriceLabel.text = ""
      self.thresholdPrice = 0
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
      if self.tradingPairs.isEmpty {
        
      }
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
          if exchangePrice != nil {
            self.thresholdPrice = thresholdPrice
            if thresholdPrice > exchangePrice {
              if isAboveSwitch.isOn {
                self.thresholdPrice = thresholdPrice
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
                self.thresholdPrice = thresholdPrice
              }
            }
          }
        }
        else {
          self.thresholdPrice = 0.0
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
