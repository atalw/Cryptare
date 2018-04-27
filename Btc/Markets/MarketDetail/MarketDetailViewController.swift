//
//  MarketDetailViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults

class MarketDetailViewController: UIViewController {
  
  let selectedColour = UIColor.init(hex: "#F7B54A")
  
  var market: [String: Any]!
  var marketName: String!
  var databaseTitle: String!

  var links: [String: Any] = [:]
  var sortedLinks: [String] = []
  
  var tradingPairData: [String: [String: Any]] = [:]
  // (coin, [base])
  var sortedTradingPairs: [(String, [String])] = []
  var fannedOutTradingPairs: [(String, String)] = []
  
  var databaseRef: DatabaseReference!
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.theme_activityIndicatorViewStyle = GlobalPicker.activityIndicatorColor
    activityIndicator.center = self.tableView.center
    activityIndicator.center.y += 100
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    
    return activityIndicator
  }()
  
  var favouriteMarkets: [String] = []
  var favouriteStatus: Bool = false
  var favouriteButton: UIBarButtonItem!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    marketName = market["name"] as! String
    self.title = marketName
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    let image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
    favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
    self.navigationItem.rightBarButtonItem = favouriteButton
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    
    links = market["links"] as! [String : Any]
    
    if links["Website"] != nil {
      sortedLinks.append("Website")
    }
    
    if links["Twitter"] != nil {
      sortedLinks.append("Twitter")
    }
    
    if links["Facebook"] != nil {
      sortedLinks.append("Facebook")
    }
    
    if links["Google+"] != nil {
      sortedLinks.append("Google+")
    }
    
    if links["Reddit"] != nil {
      sortedLinks.append("Reddit")
    }
    
    if links["Github"] != nil {
      sortedLinks.append("Github")
    }
    
    if links["Medium"] != nil {
      sortedLinks.append("Medium")
    }

    activityIndicator.startAnimating()

    if let databaseTitle = market["database_title"] as? String {
      self.databaseTitle = databaseTitle
      databaseRef = Database.database().reference()
      databaseRef.child(databaseTitle).observe(.value) { (snapshot) in
        if let dict = snapshot.value as? [String: [String: Any]] {
          
          for (key, value) in dict {
            var baseArray: [String] = []
            if self.tradingPairData[key] == nil {
              self.tradingPairData[key] = [:]
            }
            for (base, data)  in value {
              self.tradingPairData[key]![base] = data
              baseArray.append(base)
            }
            
            baseArray = baseArray.sorted(by: {$0.localizedCaseInsensitiveCompare($1) == .orderedAscending})
            
            self.sortedTradingPairs.append((key, baseArray))
          }
          self.sortedTradingPairs = self.sortedTradingPairs.sorted(by: {$0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending})
          
          for (key, baseArray) in self.sortedTradingPairs {
            for base in baseArray {
              self.fannedOutTradingPairs.append((key, base))
            }
          }
          
          self.activityIndicator.stopAnimating()
          self.tableView.reloadData()
        }
      }
    }

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard tableView != nil else { return }
    if let selectedTableIndex = tableView.indexPathForSelectedRow {
      deselectTableRow(indexPath: selectedTableIndex)
    }
    
    getFavouriteMarketsList()
    setFavouriteButtonStatus()
  }
  
  override func viewDidLayoutSubviews() {
    tableViewHeightConstraint.constant = tableView.contentSize.height + 200
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
//    tradingPairData = [:]
//    sortedTradingPairs = []
//    fannedOutTradingPairs = []
    
    databaseRef.removeAllObservers()
  }
  
  func getFavouriteMarketsList() {
    favouriteMarkets = Defaults[.favouriteMarkets]
    tableView.reloadData()
  }
  
  func setFavouriteButtonStatus() {
    
    if favouriteMarkets.contains(marketName) {
      var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
      image = image?.maskWithColor(color: selectedColour)
      favouriteButton.image = image
      favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
      self.navigationItem.rightBarButtonItem = favouriteButton
      favouriteStatus = true
    }
    else {
      var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
      image = image?.maskWithColor(color: UIColor.gray)
      favouriteButton.image = image
      favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
      self.navigationItem.rightBarButtonItem = favouriteButton
      favouriteStatus = false
    }
    
  }
  
  @objc func favouriteButtonTapped() {
    
    if favouriteStatus {
      if !favouriteMarkets.contains(marketName) {
        favouriteStatus = false
      } else {
        for index in 0..<favouriteMarkets.count {
          if marketName == favouriteMarkets[index] {
            favouriteMarkets.remove(at: index)
            break
          }
        }
        favouriteStatus = true
      }
    } else {
      if favouriteMarkets.contains(marketName) {
        favouriteStatus = false
      }
      else {
        favouriteMarkets.append(marketName)
        favouriteStatus = true
      }
    }
    
    Defaults[.favouriteMarkets] = favouriteMarkets
    setFavouriteButtonStatus()

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
      return 45
    }
    else {
      return 60
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return sortedLinks.count
    }
    else {
      return fannedOutTradingPairs.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row  = indexPath.row
    let section = indexPath.section
    
    self.tableViewHeightConstraint.constant = self.tableView.contentSize.height + 50

    if section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "link") as! MarketDetailLinkTableViewCell
      cell.selectionStyle = .none
      
      let linkName = sortedLinks[row]
      cell.socialTitleLabel.text = linkName
      if let displayLinksDict = links["display_links"] as? [String: String] {
        cell.linkLabel.text = displayLinksDict[linkName]
      }
      cell.link = links[linkName] as! String

      return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "tradingPair") as! MarketDetailTradingPairTableViewCell
      cell.selectionStyle = .none

      let (coin, base) = fannedOutTradingPairs[row]
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = indexPath.row
    let section = indexPath.section
    
    if section == 1 {
      let targetViewController = storyboard?.instantiateViewController(withIdentifier: "PairDetailContainerViewController") as! PairDetailContainerViewController
      
      let (coin, base) = fannedOutTradingPairs[row]
      targetViewController.currentPair = (coin, base)
      targetViewController.coinPairData = tradingPairData[coin]![base] as! [String : Any]
      var title: String!
      if databaseTitle == "MarketAverage" {
        title = "\(coin)/Data/\(base)"
      }
      else {
        title = "\(databaseTitle!)/\(coin)/\(base)"
      }
      
      targetViewController.currentMarket = (marketName, title)
      
      self.navigationController?.pushViewController(targetViewController, animated: true)
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
