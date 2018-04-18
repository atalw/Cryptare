//
//  AvailableExchangesTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AvailableExchangesTableViewController: UITableViewController {
  
  var cryptoParentController: AddTransactionTableViewController?
  var fiatParentController: AddFiatTransactionTableViewController?
  
  var markets: [String: String]!
  var sortedMarkets: [(String, String)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Exchanges"
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    if markets != nil {
      sortedMarkets = markets.sorted(by: {$0.key.localizedCompare($1.key) == .orderedAscending})
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Exchanges"
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return markets.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    cell.selectionStyle = .none
    
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    cell.textLabel?.theme_textColor = GlobalPicker.viewTextColor
    
    cell.textLabel?.text = sortedMarkets[indexPath.row].0
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let market = sortedMarkets[indexPath.row]
    if cryptoParentController != nil {
      cryptoParentController?.updateCurrentExchange(exchange: market)
    }
    else if fiatParentController != nil {
      fiatParentController?.updateCurrentExchange(exchange: market)
    }
    
    FirebaseService.shared.transaction_exchange_selected(name: market.0)
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
