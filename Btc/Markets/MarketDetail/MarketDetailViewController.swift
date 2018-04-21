//
//  MarketDetailViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase

class MarketDetailViewController: UIViewController {
  
  var market: [String: String]!
  var tradingPairData: [String: [String: Any]] = [:]
  
  // (coin, [base])
  var sortedTradingPairs: [(String, [String])] = []
  
  var databaseRef: DatabaseReference!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = market["name"]
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()

    if let databaseTitle = market["database_title"] {
      databaseRef = Database.database().reference()
      databaseRef.child(databaseTitle).observe(.value) { (snapshot) in
        if let dict = snapshot.value as? [String: [String: Any]] {
//          print(dict)
          self.tradingPairData = dict
          
          for (key, value) in dict {
            var baseArray: [String] = []
            for (base, data)  in value {
              baseArray.append(base)
            }
            self.sortedTradingPairs.append((key, baseArray))
          }
          self.sortedTradingPairs = self.sortedTradingPairs.sorted(by: {$0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending})
          self.tableView.reloadData()
        }
      }
    }

  }
  
  override func viewDidLayoutSubviews() {
    tableViewHeightConstraint.constant = tableView.contentSize.height + 200
    print(tableViewHeightConstraint.constant)

  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    databaseRef.removeAllObservers()
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

extension MarketDetailViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Links"
    }
    else {
      return "Available Trading Pairs"
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }
    else {
      return 60
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 5
    }
    else {
      return sortedTradingPairs.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row  = indexPath.row
    let section = indexPath.section
    
    self.tableViewHeightConstraint.constant = self.tableView.contentSize.height + 50

    if section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "link") as! MarketDetailLinkTableViewCell
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "tradingPair") as! MarketDetailTradingPairTableViewCell
      var (coin, baseArray) = sortedTradingPairs[row]
      baseArray = baseArray.sorted(by: {$0.localizedCaseInsensitiveCompare($1) == .orderedAscending})
      
      let base = baseArray.first!
      cell.tradingPairLabel.text = "\(coin)/\(base)"
      
      if let data = tradingPairData[coin]![base] as? [String: Any] {
        if let lastPrice = data["last_price"] as? Double {
          cell.currentPriceLabel.text = lastPrice.asSelectedCurrency(currency: base)
        }
        else if let buyPrice = data["buy_price"] as? Double {
          cell.currentPriceLabel.text = buyPrice.asSelectedCurrency(currency: base)
        }
      }
      
      cell.symbolImage.loadSavedImage(coin: coin)
      
      
      return cell
    }
  }
}
