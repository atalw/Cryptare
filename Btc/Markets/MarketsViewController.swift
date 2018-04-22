//
//  MarketsViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 20/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase

class MarketsViewController: UIViewController {
  
  var parentController: MarketsContainerViewController!
  
  var favouritesTab: Bool!
  
  var tradingPairs: [String] = []
  // (key, name)
  var marketNames: [(String, String)] = []
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    
    // load markets from Firebase
    if !favouritesTab {
      for market in marketInformation {

        if let name = market.value["name"] as? String {
            self.marketNames.append((market.key, name))
        }
      }
      
      marketNames = marketNames.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
    }
    else { // load markets from UserDefaults
//      getFavourites()
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
//    if favouritesTab {
//      getFavourites()
//    }
    
    tableView.reloadData()
  }
  
  
  func getFavourites() {
    let markets = Defaults[.favouriteMarkets]
    for market in markets {
      if let name = marketInformation[market]!["name"] as? String {
        self.marketNames.append((market, name))
      }
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

extension MarketsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if favouritesTab {
      return 2
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if favouritesTab {
      if section == 0 {
        return "Trading Pairs"
      }
      else {
        return "Markets"
      }
    }
    return "Markets"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if favouritesTab {
      if section == 0 {
        return 5
      }
      else {
        return marketNames.count
      }
    }
    return marketNames.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 60
    }
    else {
      return 50
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    let section = indexPath.section
    if favouritesTab {
      if section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tradingPair") as! MarketsTradingPairTableViewCell
        cell.selectionStyle = .none

        cell.coinNameLabel.text = "Bitcoin"
        return cell
      }
      else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marketShortcut") as! MarketsTableViewCell
        cell.selectionStyle = .none

        cell.exchangeTitleLabel.text = marketNames[row].1
        return cell
      }
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "marketShortcut") as! MarketsTableViewCell
      cell.selectionStyle = .none

      cell.exchangeTitleLabel.text = marketNames[row].1
      return cell
    }
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    let section = indexPath.section
    
    if favouritesTab {
      if section == 1 { // favourite markets
        let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
        targetVC.market = marketInformation[marketNames[row].0]!
        
        self.navigationController?.pushViewController(targetVC, animated: true)
      }
    }
    else {
      let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
      targetVC.market = marketInformation[marketNames[row].0]!
      
      self.navigationController?.pushViewController(targetVC, animated: true)
    }
    
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
