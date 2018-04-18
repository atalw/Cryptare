//
//  TradingPairTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class TradingPairTableViewController: UITableViewController {
  
  var parentController: AddTransactionTableViewController!
  
  var globalCoins: [String] = []
  var globalCurrencies: [String] = []

  // (quote, base)
  var tradingPairs: [(String, String)]!
  var fiatTradingPairs: [(String, String)] = []
  var cryptoTradingPairs: [(String, String)] = []
  
  var sortedFiatTradingPairs: [(String, String)] = []
  var sortedCryptoTradingPairs: [(String, String)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    FirebaseService.shared.updateScreenName(screenName: "Trading Pairs Add Transaction", screenClass: "TradingPairViewController")

    
    self.title = "Trading Pairs"
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    for (symbol, _) in GlobalValues.coins {
      globalCoins.append(symbol)
    }
    
    for (_, symbol, _, _) in GlobalValues.countryList {
      globalCurrencies.append(symbol)
    }
    
    for (_, tradingPair) in tradingPairs.enumerated() {
      if globalCoins.contains(tradingPair.1) {
        cryptoTradingPairs.append(tradingPair)
      }
      else if globalCurrencies.contains(tradingPair.1) {
        fiatTradingPairs.append(tradingPair)
      }
    }
    
    sortedCryptoTradingPairs = cryptoTradingPairs.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
    
    sortedFiatTradingPairs = fiatTradingPairs.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return sortedCryptoTradingPairs.count
    }
    else {
      return sortedFiatTradingPairs.count
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Cryptocurrency pairs"
    }
    else {
      return "Fiat pairs"
    }
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    cell.selectionStyle = .none
    
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    cell.textLabel?.theme_textColor = GlobalPicker.viewTextColor
    
    if indexPath.section == 0 {
      cell.textLabel?.text = "\(sortedCryptoTradingPairs[indexPath.row].0)-\(sortedCryptoTradingPairs[indexPath.row].1)"
    }
    else {
      cell.textLabel?.text = "\(sortedFiatTradingPairs[indexPath.row].0)-\(sortedFiatTradingPairs[indexPath.row].1)"
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var selectedPair: (String, String)
    if indexPath.section == 0 {
      selectedPair = sortedCryptoTradingPairs[indexPath.row]
    }
    else {
      selectedPair = sortedFiatTradingPairs[indexPath.row]
    }
    
    FirebaseService.shared.transaction_tradingPair_selected(pair: selectedPair)
    
    parentController.updateCurrentTradingPair(pair: selectedPair)
    navigationController?.popViewController(animated: true)
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
}
