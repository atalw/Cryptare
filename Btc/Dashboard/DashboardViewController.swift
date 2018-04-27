//
//  DashboardViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/08/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Firebase
import SwiftReorder
import SwiftyUserDefaults
import SwiftTheme

class DashboardViewController: UIViewController {
  
  var parentController: MainViewController!
  
  var currency: String!
  
  let dateFormatter = DateFormatter()
  
  var favouritesTab: Bool!
  
  var coins: [String] = []
  let greenColour = UIColor.init(hex: "#35CC4B")
  let redColour = UIColor.init(hex: "#e74c3c")
  
  var graphController: GraphViewController! // child view controller
  
  var coinData: [String: [String: Any]] = [:]
  var changedRow = 0
  
  var databaseRef: DatabaseReference!
  var listOfCoins: DatabaseReference!
  var coinRefs: [DatabaseReference] = []
  
  //    let searchController = UISearchController(searchResultsController: nil)
  var coinSearchResults = [String]()
  
  @IBOutlet weak var tableView: UITableView!
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.theme_activityIndicatorViewStyle = GlobalPicker.activityIndicatorColor
    activityIndicator.center = view.center
    activityIndicator.center.y -= 200
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    
    return activityIndicator
  }()
  
  @IBOutlet weak var rankLabel: UILabel! {
    didSet {
      rankLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var headerBackgroundView: UIView! {
    didSet {
      headerBackgroundView.isHidden = true
    }
  }
  @IBOutlet weak var header24hrChangeLabel: UILabel!
  @IBOutlet weak var headerCurrentPriceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    header24hrChangeLabel.theme_textColor = GlobalPicker.viewAltTextColor
    headerCurrentPriceLabel.theme_textColor = GlobalPicker.viewAltTextColor
    
    ThemeManager.setTheme(index: Defaults[.currentThemeIndex])
    
    self.currency = GlobalValues.currency!
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    
    databaseRef = Database.database().reference()
    
    listOfCoins = databaseRef.child("coins")
    
    var allCoins: [String] = []
    
    activityIndicator.startAnimating()
    listOfCoins.observeSingleEvent(of: .value, with: { (snapshot) in
      if let dict = snapshot.value as? [String: [String: Any]] {
        let sortedDict = dict.sorted(by: { ($0.1["rank"] as! Int) < ($1.1["rank"] as! Int)})
        self.coins = []
        GlobalValues.coins = []
        self.tableView.reloadData()
        
        for (coin, values) in sortedDict {
          allCoins.append(coin)
          
          if self.coinData[coin] == nil {
            self.coinData[coin] = [:]
          }
          
          if let name = values["name"] as? String {
            self.coinData[coin]!["name"] = name
            GlobalValues.coins.append((coin, name))
          }
          
          if let rank = values["rank"] as? Int {
            self.coinData[coin]!["rank"] = rank
          }
          if let iconUrl = values["icon_url"] as? String {
            self.coinData[coin]!["iconUrl"] = iconUrl
          }
        }
      }
      if !self.favouritesTab {
        FirebaseService.shared.updateScreenName(screenName: "All Dashboard", screenClass: "DashboardViewController")
        self.coins = allCoins
      }
      else {
        // for reorder ability
        FirebaseService.shared.updateScreenName(screenName: "Favourites Dashboard", screenClass: "FavouritesDashboardViewController")
        
        self.tableView.reorder.delegate = self
      }
      
      self.loadAllCoinData()
    })
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    databaseRef = Database.database().reference()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if currentReachabilityStatus == .notReachable {
      let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
      present(alert, animated: true, completion: nil)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    databaseRef.removeAllObservers()
    listOfCoins.removeAllObservers()
    
    for coinRef in coinRefs {
      coinRef.removeAllObservers()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  func getFavourites() {
    self.coins = Defaults[.dashboardFavourites]
  }
  
  func loadAllCoinData() {
    if favouritesTab {
      self.getFavourites()
      
      if coins.count == 0 {
        let messageLabel = UILabel()
        messageLabel.text = "No coins added to your favourites"
        messageLabel.theme_textColor = GlobalPicker.viewTextColor
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
      }
      else {
        tableView.backgroundView = nil
      }
    }
    headerBackgroundView.isHidden = false
    activityIndicator.stopAnimating()
    self.setupCoinRefs()
  }
  
  func setupCoinRefs() {
//    coinData = [:]
    for coin in self.coins {
      if coinData[coin] == nil {
        self.coinData[coin] = [:]
      }
//      self.coinData[coin]!["rank"] = 0
      self.coinData[coin]!["currentPrice"] = 0.0
      self.coinData[coin]!["timestamp"] = 0.0
      self.coinData[coin]!["volume24hrs"] = 0.0
      self.coinData[coin]!["percentageChange24hrs"] = 0.0
      self.coinData[coin]!["priceChange24hrs"] = 0.0
    }
    
    for coinRef in coinRefs {
      coinRef.removeAllObservers()
    }
    
    coinRefs = []
    
    for coin in self.coins {
      self.coinRefs.append(self.databaseRef.child(coin).child("Data").child(currency))
    }
    
    for coinRef in self.coinRefs {
      coinRef.observe(.value, with: {(snapshot) -> Void in
        if let dict = snapshot.value as? [String : AnyObject] {
          if let index = self.coinRefs.index(of: coinRef) {
            let coin = self.coins[index]
            self.changedRow = index
            self.updateCoinDataStructure(coin: coin, dict: dict)
          }
        }
      })
    }
  }
  
  func updateCoinDataStructure(coin: String, dict: [String: Any]) {
    
    if coinData[coin]!["oldPrice"] == nil {
      coinData[coin]!["oldPrice"] = 0.0
    }
    else {
      coinData[coin]!["oldPrice"] = self.coinData[coin]!["currentPrice"]
    }
    if let currentPrice = dict["price"] as? Double {
      coinData[coin]!["currentPrice"] = currentPrice
    }
    if let volume24hrs = dict["vol_24hrs_currency"] as? Double {
      coinData[coin]!["volume24hrs"] = volume24hrs
    }
    if let percentageChange24hours = dict["change_24hrs_percent"] as? Double {
      let roundedPercentage = Double(round(1000*percentageChange24hours)/1000)
      coinData[coin]!["percentageChange24hrs"] = roundedPercentage
      
    }
    if let priceChange24hrs = dict["change_24hrs_fiat"] as? Double {
      coinData[coin]!["priceChange24hrs"] = priceChange24hrs
    }
    if let timestamp = dict["timestamp"] as? Double {
      coinData[coin]!["timestamp"] = timestamp
    }
    
    if let volumeCoin = dict["vol_24hrs_coin"] as? Double {
      coinData[coin]!["volume24hrsCoin"] = Double(round(1000*volumeCoin)/1000)
    }
//    self.coinData["volume24hrsFiat"] = dict!["vol_24hrs_fiat"] as! Double
    
    if let high = dict["high_24hrs"] as? Double {
      coinData[coin]!["high24hrs"] = high
    }
    
    if let low = dict["low_24hrs"] as? Double {
      coinData[coin]!["low24hrs"] = low
    }
    
    if let lastTradedMarket = dict["last_trade_market"] as? String {
      coinData[coin]!["lastTradeMarket"] = lastTradedMarket
    }
    if let lastTradeVolume = dict["last_trade_volume"] as? Double {
      coinData[coin]!["lastTradeVolume"] = lastTradeVolume
    }
    
    if let supply = dict["supply"] as? Double {
      coinData[coin]!["supply"] = supply
    }
    
    if let marketcap =  dict["marketcap"] as? Double {
      coinData[coin]!["marketcap"] = marketcap
    }
    
    tableView.reloadData()

  }
  
  func isFiltering() -> Bool {
    return parentController.searchController.isActive && !searchBarIsEmpty()
  }
  
  func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return parentController.searchController.searchBar.text?.isEmpty ?? true
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    let destinationViewController = segue.destination
    if let graphController = destinationViewController as? GraphViewController {
      self.graphController = graphController
    }
  }
  
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return coinSearchResults.count
    }
    return coins.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if favouritesTab {
      if let spacer = tableView.reorder.spacerCell(for: indexPath) {
        return spacer
      }
    }
    
    var coin: String
    if isFiltering() {
      coin = coinSearchResults[indexPath.row]
    }
    else {
      coin = coins[indexPath.row]
    }
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "coinCell") as? CoinTableViewCell
    
    cell!.selectionStyle = .none
    if !favouritesTab {
      if let rank = self.coinData[coin]?["rank"] as? Int {
        cell!.coinRank.text = "\(rank)"
        cell!.coinRank.adjustsFontSizeToFitWidth = true
      }
    }
    
    cell!.coinSymbolLabel.text = coin
    cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
    
    if !favouritesTab {
      if let urlString = self.coinData[coin]?["iconUrl"] as? String {
        cell!.coinSymbolImage.loadSavedImageWithURL(coin: coin, urlString: urlString)
      }
    }
    else {
      cell!.coinSymbolImage.loadSavedImage(coin: coin)
    }
    
    cell!.coinSymbolImage.contentMode = .scaleAspectFit
    
    for (symbol, name) in GlobalValues.coins {
      if symbol == coin {
        cell!.coinNameLabel.text = name
      }
    }
    
    var colour: UIColor
    
    if let currentPrice = self.coinData[coin]?["currentPrice"] as? Double {
      let oldPrice = self.coinData[coin]?["oldPrice"] as? Double ?? 0.0
      
      if  currentPrice > oldPrice {
        colour = self.greenColour
      }
      else if currentPrice < oldPrice {
        colour = self.redColour
      }
      else {
        colour = cell!.coinCurrentValueLabel.textColor
      }
      
      cell!.coinCurrentValueLabel.adjustsFontSizeToFitWidth = true
      cell!.coinCurrentValueLabel.text = currentPrice.asCurrency
      if changedRow == indexPath.row {
        UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
          cell!.coinCurrentValueLabel.textColor = colour
        }, completion: { finished in
          UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 1.5, options: .transitionCrossDissolve, animations: {
            cell!.coinCurrentValueLabel.theme_textColor = GlobalPicker.viewTextColor
          }, completion: nil)
        })
        
        changedRow = -1
      }
    }
    
    self.dateFormatter.dateFormat = "h:mm a"
    
    if let timestamp = self.coinData[coin]?["timestamp"] as? Double {
      cell!.coinTimestampLabel.text =  self.dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
      cell!.coinTimestampLabel.adjustsFontSizeToFitWidth = true
    }
    
    if let percentageChange = self.coinData[coin]?["percentageChange24hrs"] as? Double {
      cell!.coinPercentageChangeLabel.text = "\(percentageChange)%"
      
      if percentageChange > 0 {
        cell!.coinPercentageChangeLabel.textColor = greenColour
        colour = greenColour
      }
      else if percentageChange < 0 {
        cell!.coinPercentageChangeLabel.textColor = redColour
        colour = redColour
      }
      else {
        cell!.coinPercentageChangeLabel.theme_textColor = GlobalPicker.viewTextColor
      }
      
      if let priceChange = self.coinData[coin]?["priceChange24hrs"] as? Double {
        cell!.coinPriceChangeLabel.text = priceChange.asCurrency
        cell!.coinPriceChangeLabel.adjustsFontSizeToFitWidth = true
        let colour = cell!.coinPercentageChangeLabel.textColor
        cell!.coinPriceChangeLabel.textColor = colour
      }
    }
    
    cell!.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let targetViewController = storyboard?.instantiateViewController(withIdentifier: "graphViewController") as! GraphViewController
    
    if isFiltering() {
      let coin = self.coinSearchResults[indexPath.row]
      targetViewController.databaseTableTitle = coin
      targetViewController.coinData = self.coinData[coin]!
    }
    else {
      let coin = self.coins[indexPath.row]
      targetViewController.databaseTableTitle = coin
      targetViewController.coinData = self.coinData[coin]!
    }
    
    FirebaseService.shared.dashboard_coin_tapped(coin: targetViewController.databaseTableTitle)
    
    self.navigationController?.pushViewController(targetViewController, animated: true)
    
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
}

extension DashboardViewController: TableViewReorderDelegate {
  func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
    // Update data model
    let destinationCoin = coins[destinationIndexPath.row]
    coins[destinationIndexPath.row] = coins[sourceIndexPath.row]
    coins[sourceIndexPath.row] = destinationCoin
    
    Defaults[.dashboardFavourites] = coins
  }
}




