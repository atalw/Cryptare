//
//  PairAlertViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class PairAlertViewController: UIViewController {
  
  // For testing
  
  let testingAlertData: [String: [String: [String: [[String: Any]]]]] = ["Coinbase" : [
    "ETH" : [
      "USD" : [ [
        "thresholdPrice": 500,
        "isAbove": false,
        "isActive": true,
        "databaseTitle": "coinbase/ETH/USD",
        "date": "21 Apr, 2018",
        "type": "single"
        ] ]
    ],
    "BTC" : [
      "USD" : [ [
        "thresholdPrice": 8200,
        "isAbove": true,
        "isActive": false,
        "databaseTitle": "coinbase/BTC/USD",
        "date": "21 Apr, 2018",
        "type": "single"
        ] ]
    ]
    ]]
  
  var currentPair: (String, String)?
  var currentMarket: (String, String)?
  var exchangePrice: Double?
  
  var parentController: PairDetailContainerViewController?
  
  var alerts: [Alert] = [] {
    didSet {
      if alerts.count > 0 {
        tableView.backgroundView = nil
      }
      else {
        let messageLabel = UILabel()
        messageLabel.text = "You have no alerts."
        messageLabel.theme_textColor = GlobalPicker.viewTextColor
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
      }
    }
  }
  var alertsDict: [String: Any] = [:]
  
  lazy var refreshControl: UIRefreshControl = {
    
    let refreshControl = UIRefreshControl()
//    let title = NSLocalizedString("Pull to refresh", comment: "Pull to refresh")
//
//    refreshControl.attributedTitle = NSAttributedString(string: title)
  
    refreshControl.addTarget(self, action:
      #selector(handleRefresh(_:)),
                             for: UIControlEvents.valueChanged)
    
    refreshControl.theme_tintColor = GlobalPicker.viewTextColor
    
    return refreshControl
  }()
  
//  var alertsFirebase: [AlertFirebase] = []
  
  @IBOutlet weak var scrollView: UIScrollView! {
    didSet {
//      scrollView.addSubview(refreshControl)
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      let messageLabel = UILabel()
      messageLabel.text = "You have no alerts."
      messageLabel.theme_textColor = GlobalPicker.viewTextColor
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      
      tableView.backgroundView = messageLabel
    }
  }
  
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    if #available(iOS 11.0, *) {
//      self.navigationController?.navigationBar.prefersLargeTitles = true
//    } else {
//      // Fallback on earlier versions
//    }
    
//    if Defaults[.mainAlertsIntroComplete] {
//      let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
//      if notificationType == [] {
//        print("notifications are NOT enabled")
//      } else {
//        print("notifications are enabled")
//      }
//    }
    
    let introComplete = Defaults[.mainAlertsIntroComplete]
    
    if !introComplete {
      let introViewController = storyboard?.instantiateViewController(withIdentifier: "AlertsIntroViewController") as! AlertsIntroViewController
      
      self.navigationController?.present(introViewController, animated: true, completion: nil)
    }
    
    
//    self.title = "Alerts"
    
    if parentController == nil {
//      self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.allowsSelection = false
//    let insets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
//    self.tableView.contentInset = insets
    
    self.extendedLayoutIncludesOpaqueBars = true
    
    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      // Fallback on earlier versions
      tableView.addSubview(refreshControl)
      
    }
    
    // for testing-------------------------------------------
    //    Defaults[.allCoinAlerts] = testingAlertData
    
    // --------------------------------------------------------
    loadAlerts()

    self.tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadAlertsFromDefaults()
  }
  
  func loadAlerts() {
    if Auth.auth().currentUser?.uid != nil {
      let uid = Auth.auth().currentUser?.uid
      let coinAlertRef = Database.database().reference().child("coin_alerts").child(uid!)
      coinAlertRef.keepSynced(true)
      coinAlertRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
          if let alertsDict = snapshot.value as? [String: Any] {
            self.alertsDict = alertsDict
            if self.currentPair != nil && self.currentMarket != nil {
              self.getAlertsFor(alerts: alertsDict, tradingPair: self.currentPair!, market: self.currentMarket!)
            }
            else {
              self.getAllAlerts(alertsDict: alertsDict)
            }
            
            self.sortAlertsByDate()
            self.tableView.reloadData()
          }
        }
        else {
          self.getAllAlerts(alertsDict: [:])
        }
      })
    }
  }
  
  func loadAlertsFromDefaults() {
    self.alerts = []
    let alertsDict = Defaults[.allCoinAlerts]
    if self.currentPair != nil && self.currentMarket != nil {
      self.getAlertsFor(alerts: alertsDict, tradingPair: self.currentPair!, market: self.currentMarket!)
    }
    else {
      self.getAllAlerts(alertsDict: alertsDict)
    }
    
    sortAlertsByDate()
    self.tableView.reloadData()
  }
  
  func sortAlertsByDate() {
    alerts = alerts.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
  }
  
  func getAllAlerts(alertsDict: [String: Any]) {
    self.alerts = []
    let allCoinAlerts = alertsDict
    for (exchange, data) in allCoinAlerts {
      guard let exchangeData = data as? [String: Any] else { continue }
      
      for (coin, coinData) in exchangeData {
        guard let alertData = coinData as? [String: Any] else { continue }
        
        for (pair, alertsArray) in alertData {
          guard let alerts = alertsArray as? [[String: Any]] else { continue }
          
          for alert in alerts {
            guard let date = alert["date"] as? String else { continue }
            guard let isAbove = alert["isAbove"] as? Bool else { continue }
            guard let thresholdPrice = alert["thresholdPrice"] as? Double else { continue }
            guard let databaseTitle = alert["databaseTitle"] as? String else { continue }
            guard let isActive = alert["isActive"] as? Bool else { continue }
            guard let type = alert["type"] as? String else { continue }
            
            let tradingPair = (coin, pair)
            let market = (exchange, databaseTitle)
            
            self.alerts.append(Alert(date: date, isAbove: isAbove, thresholdPrice: thresholdPrice, tradingPair: tradingPair, exchange: market, isActive: isActive, type: type, databaseTitle: databaseTitle))
          }
        }
      }
    }
    Defaults[.allCoinAlerts] = allCoinAlerts
    Defaults[.numberOfCoinAlerts] = alerts.count
  }
  
  func getAlertsFor(alerts: [String: Any], tradingPair: (String, String), market: (String, String)) {
    self.alerts = []
    let allCoinAlerts = alerts
    for (exchange, data) in allCoinAlerts {
      if exchange != market.0 { continue }
      guard let exchangeData = data as? [String: Any] else { continue }
      
      for (coin, coinData) in exchangeData {
        if coin != tradingPair.0 { continue }
        guard let alertData = coinData as? [String: Any] else { continue }
        
        for (pair, alertsArray) in alertData {
          if pair != tradingPair.1 { continue }
          guard let alerts = alertsArray as? [[String: Any]] else { continue }
          
          for alert in alerts {
            guard let date = alert["date"] as? String else { continue }
            guard let isAbove = alert["isAbove"] as? Bool else { continue }
            guard let thresholdPrice = alert["thresholdPrice"] as? Double else { continue }
            guard let databaseTitle = alert["databaseTitle"] as? String else { continue }
            guard let isActive = alert["isActive"] as? Bool else { continue }
            guard let type = alert["type"] as? String else { continue }
            
            let tradingPair = (coin, pair)
            let market = (exchange, databaseTitle)
            
            self.alerts.append(Alert(date: date, isAbove: isAbove, thresholdPrice: thresholdPrice, tradingPair: tradingPair, exchange: market, isActive: isActive, type: type, databaseTitle: databaseTitle))
            
          }
        }
      }
    }
  }
  
  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    alerts = []
    tableView.reloadData()
    loadAlertsFromDefaults()
    refreshControl.endRefreshing()
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVc = segue.destination
    if let addAlertVc = destinationVc as? AddPairAlertViewController {
      addAlertVc.parentController = self
      addAlertVc.tradingPair = self.currentPair
      addAlertVc.exchange = self.currentMarket
      addAlertVc.exchangePrice = self.exchangePrice
    }
  }
}

extension PairAlertViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  //  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
  //    return "Alerts"
  //  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alerts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    tableViewHeightConstraint.constant = tableView.contentSize.height + 150
    
    let row = indexPath.row
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as! PairAlertTableViewCell
    cell.selectionStyle = .none
    
    let alert = alerts[row]
    
    cell.dateLabel.text = "Created on \(alert.date)"
    
    if alert.isAbove {
      cell.aboveLabel.text = "1 \(alert.tradingPair.0) >"
    }
    else {
      cell.aboveLabel.text = "1 \(alert.tradingPair.0)  <"
    }
    
    cell.thresholdPriceLabel.text = alert.thresholdPrice.asSelectedCurrency(currency: alert.tradingPair.1)


    cell.tradingPairLabel.text = "\(alert.tradingPair.0)/\(alert.tradingPair.1)"

    cell.exchangeLabel.text = alert.exchange.0
    
    cell.isActiveSwitch.setOn(alert.isActive, animated: true)
    
    cell.isActiveSwitch.tag = row
    cell.isActiveSwitch.addTarget(self, action: #selector(isActiveSwitchChanged), for: .valueChanged)
    
    return cell
  }
  
  @objc func isActiveSwitchChanged(sender: UISwitch) {
    let rowChanged = sender.tag
    let alert = self.alerts[rowChanged]
    alert.isActive = sender.isOn
    
    let exchangeName = alert.exchange.0
    let baseCoin = alert.tradingPair.0
    let quoteCoin = alert.tradingPair.1
    
    var allCoinAlerts = self.alertsDict
    
    outerLoop: for (exchange, data) in allCoinAlerts {
      
      if exchange != exchangeName { continue }
      guard var exchangeData = data as? [String: Any] else { return }
      
      for (base, coinData) in exchangeData {
        if base != baseCoin { continue }
        guard var alertData = coinData as? [String: Any] else { continue }
        
        for (quote, alertsArray) in alertData {
          if quote != quoteCoin { continue }
          guard var alerts = alertsArray as? [[String: Any]] else { continue }
          
          for (index, alertValues) in alerts.enumerated() {
            guard let date = alertValues["date"] as? String else { continue }
            guard let isAbove = alertValues["isAbove"] as? Bool else { continue }
            guard let thresholdPrice = alertValues["thresholdPrice"] as? Double else { continue }
            guard let databaseTitle = alertValues["databaseTitle"] as? String else { continue }
            guard let type = alertValues["type"] as? String else { continue }
            
            if date == alert.date && isAbove == alert.isAbove && thresholdPrice == alert.thresholdPrice && type == alert.type && databaseTitle == alert.databaseTitle {
              
              alerts[index]["isActive"] = alert.isActive
              alertData[quote] = alerts
              exchangeData[base] = alertData
              allCoinAlerts[exchange] = exchangeData
              break outerLoop
            }
          }
        }
      }
    }
    self.alertsDict = allCoinAlerts
    Defaults[.allCoinAlerts] = allCoinAlerts
    FirebaseService.shared.update_coin_alerts(data: allCoinAlerts)
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let row = indexPath.row
//    let section = indexPath.section
    
    //    if favouritesTab {
    //      if section == 1 { // favourite markets
    //        let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
    //        targetVC.market = marketInformation[marketNames[row].0]!
    //
    //        self.navigationController?.pushViewController(targetVC, animated: true)
    //      }
    //    }
    //    else {
    //      let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
    //      targetVC.market = marketInformation[marketNames[row].0]!
    //
    //      self.navigationController?.pushViewController(targetVC, animated: true)
    //    }
    
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
      // delete item at indexPath
      let alert = self.alerts[indexPath.row]
      self.alerts.remove(at: indexPath.row)
      self.tableViewHeightConstraint.constant = tableView.contentSize.height + 150
      self.deleteAlert(alert: alert)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    return [delete]
  }
  
//  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//    guard let cell = tableView.cellForRow(at: indexPath) else { return }
//    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
//  }
//
//  func deselectTableRow(indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//    tableView(tableView, didDeselectRowAt: indexPath)
//  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
  func deleteAlert(alert: Alert) {
    
    let exchangeName = alert.exchange.0
    let baseCoin = alert.tradingPair.0
    let quoteCoin = alert.tradingPair.1
    
    var allCoinAlerts = self.alertsDict
    
    outerLoop: for (exchange, data) in allCoinAlerts {
      
      if exchange != exchangeName { continue }
      guard var exchangeData = data as? [String: Any] else { continue }
      
      for (base, coinData) in exchangeData {
        if base != baseCoin { continue }
        guard var alertData = coinData as? [String: Any] else { continue }
        
        for (quote, alertsArray) in alertData {
          if quote != quoteCoin { continue }
          guard var alerts = alertsArray as? [[String: Any]] else { continue }
          
          for (index, alertValues) in alerts.enumerated() {
            guard let date = alertValues["date"] as? String else { continue }
            guard let isAbove = alertValues["isAbove"] as? Bool else { continue }
            guard let thresholdPrice = alertValues["thresholdPrice"] as? Double else { continue }
            guard let databaseTitle = alertValues["databaseTitle"] as? String else { continue }
            guard let isActive = alertValues["isActive"] as? Bool else { continue }
            guard let type = alertValues["type"] as? String else { continue }
            
            if date == alert.date && isAbove == alert.isAbove && thresholdPrice == alert.thresholdPrice && isActive == alert.isActive && type == alert.type && databaseTitle == alert.databaseTitle {
              
              alerts.remove(at: index)
              if alerts.count == 0 {
                alertData[quote] = nil
              }
              else {
                alertData[quote] = alerts
              }
              exchangeData[base] = alertData
              allCoinAlerts[exchange] = exchangeData
              break outerLoop
            }
          }
        }
      }
    }
    self.alertsDict = allCoinAlerts
    Defaults[.allCoinAlerts] = allCoinAlerts
    Defaults[.numberOfCoinAlerts] = alerts.count

    FirebaseService.shared.update_coin_alerts(data: allCoinAlerts)
    FirebaseService.shared.remove_users_coin_alerts(exchangeName: alert.exchange.0, tradingPair: alert.tradingPair)
    
  }
}
