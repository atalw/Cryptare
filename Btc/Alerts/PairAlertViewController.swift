//
//  PairAlertViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PairAlertViewController: UIViewController {
  
  // For testing
  
  let testingAlertData = ["Coinbase" : [
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
  
  var parentController: PairDetailContainerViewController?
  
  var alerts: [Alert] = []
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Alerts"
    
    if parentController == nil {
      self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    
    // for testing-------------------------------------------
    Defaults[.allCoinAlerts] = testingAlertData
    
    // --------------------------------------------------------
    
    if currentPair == nil || currentMarket == nil {
      getAllAlerts()
    }
    else {
      getAlertsFor(tradingPair: currentPair!, market: currentMarket!)
    }
    
    print(alerts.count)
    self.tableView.reloadData()
  }
  
  func getAllAlerts() {
    let allCoinAlerts = Defaults[.allCoinAlerts]
    for (exchange, data) in allCoinAlerts {
      guard let exchangeData = data as? [String: Any] else { return }
      
      for (coin, coinData) in exchangeData {
        guard let alertData = coinData as? [String: Any] else { return }
        
        for (pair, alertsArray) in alertData {
          guard let alerts = alertsArray as? [[String: Any]] else { return }
          
          for alert in alerts {
            guard let date = alert["date"] as? String else { return }
            guard let isAbove = alert["isAbove"] as? Bool else { return }
            guard let thresholdPrice = alert["thresholdPrice"] as? Double else { return }
            guard let databaseTitle = alert["databaseTitle"] as? String else { return }
            guard let isActive = alert["isActive"] as? Bool else { return }
            guard let type = alert["type"] as? String else { return }
            
            let tradingPair = (coin, pair)
            let market = (exchange, databaseTitle)
            
            self.alerts.append(Alert(date: date, isAbove: isAbove, thresholdPrice: thresholdPrice, tradingPair: tradingPair, exchange: market, isActive: isActive, type: type))
          }
        }
      }
    }
  }
  
  func getAlertsFor(tradingPair: (String, String), market: (String, String)) {
    print(tradingPair, market)
    let allCoinAlerts = Defaults[.allCoinAlerts]
    for (exchange, data) in allCoinAlerts {
      if exchange != market.0 { continue }
      guard let exchangeData = data as? [String: Any] else { return }
      
      for (coin, coinData) in exchangeData {
        if coin != tradingPair.0 { continue }
        guard let alertData = coinData as? [String: Any] else { return }
        
        for (pair, alertsArray) in alertData {
          if pair != tradingPair.1 { continue }
          guard let alerts = alertsArray as? [[String: Any]] else { return }
          
          for alert in alerts {
            guard let date = alert["date"] as? String else { return }
            guard let isAbove = alert["isAbove"] as? Bool else { return }
            guard let thresholdPrice = alert["thresholdPrice"] as? Double else { return }
            guard let databaseTitle = alert["databaseTitle"] as? String else { return }
            guard let isActive = alert["isActive"] as? Bool else { return }
            guard let type = alert["type"] as? String else { return }
            
            let tradingPair = (coin, pair)
            let market = (exchange, databaseTitle)
            
            self.alerts.append(Alert(date: date, isAbove: isAbove, thresholdPrice: thresholdPrice, tradingPair: tradingPair, exchange: market, isActive: isActive, type: type))
          }
        }
      }
    }
  }
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVc = segue.destination
    if let addAlertVc = destinationVc as? AddPairAlertViewController {
      addAlertVc.tradingPair = self.currentPair
      addAlertVc.exchange = self.currentMarket
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
    let row = indexPath.row
    let section = indexPath.section
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as! PairAlertTableViewCell
    let alert = alerts[row]
    
    cell.dateLabel.text = alert.date
    
    if alert.isAbove {
      cell.aboveLabel.text = ">"
    }
    else {
      cell.aboveLabel.text = "<"
    }
    
    cell.thresholdPriceLabel.text = alert.thresholdPrice.asSelectedCurrency(currency: alert.tradingPair.1)
    
    
    cell.tradingPairLabel.text = "\(alert.tradingPair.0)/\(alert.tradingPair.1)"
    
    cell.exchangeLabel.text = alert.exchange.0
    
    if alert.isActive {
      cell.isActiveSwitch.setOn(true, animated: true)
    }
    else {
      cell.isActiveSwitch.setOn(false, animated: true)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    let section = indexPath.section
    
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
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  func deselectTableRow(indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    tableView(tableView, didDeselectRowAt: indexPath)
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
}
