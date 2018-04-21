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
        return 5
      }
    }
    return marketNames.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    let section = indexPath.section
    
    if favouritesTab {
      if section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tradingPair") as! MarketsTradingPairTableViewCell
        
        cell.coinNameLabel.text = "Bitcoin"
        return cell
      }
      else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "marketShortcut") as! MarketsTableViewCell
//        cell.exchangeTitleLabel.text = marketNames[row]
        return cell
      }
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "marketShortcut") as! MarketsTableViewCell
      cell.exchangeTitleLabel.text = marketNames[row].1
      return cell
    }
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    let section = indexPath.section
    
    if favouritesTab {
      
    }
    else {
      let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
      targetVC.market = marketInformation[marketNames[row].0]!
      
      self.navigationController?.pushViewController(targetVC, animated: true)

    }
    
  }
}
