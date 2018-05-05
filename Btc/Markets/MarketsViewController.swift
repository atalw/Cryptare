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
import SwiftReorder

class MarketsViewController: UIViewController {
  
  var parentController: MarketsContainerViewController!
  
  var favouritesTab: Bool!
  
  var favouriteTradingPairsDict: [String: [String: [[String: String]]]] = [:]
  // (key, name)
  var marketNames: [(String, String)] = []
  
  var sortedTradingPairs: [(String, [(String, String, String)])] = []
  var fannedOutTradingPairs: [(String, String, String, String)] = []
  var tradingPairRefs: [(String, String, String, String, DatabaseReference)] = []
  
  var tradingPairDataDict: [String: [String: [String: [String: Any]]]] = [:]
  
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

        if let name = market.value["name"] as? String, let isActive = market.value["is_active"] as? Bool {
          if isActive {
            self.marketNames.append((market.key, name))
          }
        }
      }
      
      marketNames = marketNames.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
    }
    else { // load markets from UserDefaults
      self.tableView.reorder.delegate = self
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.reloadData()
  }
  
  override func viewWillLayoutSubviews() {
    if favouritesTab {
      if fannedOutTradingPairs.count == 0 && marketNames.count == 0 {
        let messageLabel = UILabel()
        messageLabel.text = "No favourite trading pairs and markets."
        messageLabel.theme_textColor = GlobalPicker.viewTextColor
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    for tradingPairRef in tradingPairRefs {
      tradingPairRef.4.removeAllObservers()
    }
  }
  
  
  func getFavourites() {
    getFavouriteTradingPairs()
    getFavouriteMarkets()
    
    getFirebasePairData()
  }
  
  func getFavouriteTradingPairs() {
    // favourite trading pairs
    let tradingPairs = Defaults[.favouritePairs]
    
    if let dict = tradingPairs as? [String: [String: [[String: String]]]] {
      self.favouriteTradingPairsDict = dict
    }
    
    for (coin, value) in tradingPairs {
      guard let coinData = value as? [String: Any] else { return }
      var baseArray: [(String, String, String)] = []
      
      for (pair, pairValue) in coinData {
        guard let pairArray = pairValue as? [[String: String]] else { return }
        
        for pairData in pairArray {
          if let marketName = pairData["name"], let databaseTitle = pairData["databaseTitle"] {
            baseArray.append((pair, marketName, databaseTitle))
            let ref = Database.database().reference().child(databaseTitle)
            tradingPairRefs.append((coin, pair, marketName, databaseTitle, ref))
          }
        }
      }
      
      baseArray = baseArray.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
      
      self.sortedTradingPairs.append((coin, baseArray))
      
    }
    
    self.sortedTradingPairs = self.sortedTradingPairs.sorted(by: {$0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending})
    
    for (key, baseArray) in self.sortedTradingPairs {
      for base in baseArray {
        self.fannedOutTradingPairs.append((key, base.0, base.1, base.2))
      }
    }
  }
  
  func getFavouriteMarkets() {
    // favourite markets
    let markets = Defaults[.favouriteMarkets]
    for market in markets {
      if let name = marketInformation[market]!["name"] as? String, let isActive = marketInformation[market]!["is_active"] as? Bool {
        if isActive {
          self.marketNames.append((market, name))
        }
      }
    }
  }
  
  func getFirebasePairData() {
    for tradingPairRef in tradingPairRefs {
      let coin = tradingPairRef.0
      let pair = tradingPairRef.1
      let market = tradingPairRef.2
      tradingPairRef.4.keepSynced(true)
      tradingPairRef.4.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
        if let cryptoDict = snapshot.value as? [String : AnyObject] {
          
          if self.tradingPairDataDict[coin] == nil {
            self.tradingPairDataDict[coin] = [:]
          }
          
          if self.tradingPairDataDict[coin]![pair] == nil {
            self.tradingPairDataDict[coin]![pair] = [:]
          }
          
          if self.tradingPairDataDict[coin]![pair]![market] == nil {
            self.tradingPairDataDict[coin]![pair]![market] = [:]
          }
          
          if let price = cryptoDict["buy_price"] as? Double {
            self.tradingPairDataDict[coin]![pair]![market]!["price"] = price
          }
          else if let price = cryptoDict["price"] as? Double {
            self.tradingPairDataDict[coin]![pair]![market]!["price"] = price
          }
          
          if let volume = cryptoDict["vol_24hrs"] as? Double {
            self.tradingPairDataDict[coin]![pair]![market]!["volume"] = volume
          }
          
          if let perChange = cryptoDict["per_change_24hrs"] as? Double {
            self.tradingPairDataDict[coin]![pair]![market]!["perChange"] = perChange
          }
          
          self.tableView.reloadData()

        }
      })
    }
  }
  
  func resetFavourites() {
    favouriteTradingPairsDict = [:]
    sortedTradingPairs = []
    fannedOutTradingPairs = []
    tradingPairRefs = []
    marketNames = []
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
        return "Favourite Trading Pairs"
      }
      else {
        return "Favourite Markets"
      }
    }
    return "Markets"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if favouritesTab {
      if section == 0 {
        return fannedOutTradingPairs.count
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
        
        let (coin, base, market, _) = fannedOutTradingPairs[row]

        cell.coinSymbolImage.loadSavedImage(coin: coin)
        
        for (symbol, name) in GlobalValues.coins {
          if symbol == coin {
            cell.coinNameLabel.text = name
            break
          }
        }
        
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
          return spacer
        }
        
        cell.tradingPairLabel.text = "\(coin)/\(base)"
        cell.exchangeLabel.text = market
        if let price = self.tradingPairDataDict[coin]?[base]?[market]?["price"] as? Double {
          cell.currentPriceLabel.text = price.asSelectedCurrency(currency: base)
        }
        
        if let volume = self.tradingPairDataDict[coin]?[base]?[market]?["volume"] as? Double {
          let roundedVolume = round(100*volume)/100
          cell.percentageChangeLabel.text = "\(roundedVolume.asSelectedCurrency(currency: coin)) in 24 hrs"
        }
        else {
          cell.percentageChangeLabel.text = "NA in 24 hrs"
        }
        
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
      if section == 0 { // favourite trading pairs
        let targetVC = storyboard?.instantiateViewController(withIdentifier: "PairDetailContainerViewController") as! PairDetailContainerViewController
        
        let (coin, base, market, databaseTitle) = fannedOutTradingPairs[row]
        targetVC.coinPairData = self.tradingPairDataDict[coin]?[base]
        targetVC.currentPair = (coin, base)
        targetVC.currentMarket = (market, databaseTitle)
        
        FirebaseService.shared.all_markets_trading_pair_tapped(coin: coin, pair: base, exchange: market)
        
        self.navigationController?.pushViewController(targetVC, animated: true)
      }
      else if section == 1 { // favourite markets
        let targetVC = storyboard?.instantiateViewController(withIdentifier: "MarketDetailViewController") as! MarketDetailViewController
        targetVC.market = marketInformation[marketNames[row].0]!
        
        FirebaseService.shared.all_markets_exchange_tapped(exchange: marketNames[row].0)
        
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

extension MarketsViewController: TableViewReorderDelegate {
  func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
    // Update data model
    let destinationCoin = marketNames[destinationIndexPath.row]
    marketNames[destinationIndexPath.row] = marketNames[sourceIndexPath.row]
    marketNames[sourceIndexPath.row] = destinationCoin
    
    Defaults[.favouriteMarkets] = marketNames.map{ $0.1 }
  }
}
