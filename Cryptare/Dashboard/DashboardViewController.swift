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
import PagedArray

class DashboardViewController: UIViewController {
  
  var parentController: MainViewController!
  
  var pagedArray: PagedArray<String>!
  
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
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.tableFooterView = UIView(frame: .zero)
    }
  }
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(frame: .zero)
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
    
    databaseRef = Database.database().reference()
    
    listOfCoins = databaseRef.child("coins")
    
    var allCoins: [String] = []
    var cryptoSymbolNamePairs: [String: String] = [:]
    
    activityIndicator.startAnimating()
    listOfCoins.keepSynced(true)
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
            cryptoSymbolNamePairs[coin] = name
            
          }
          
          if let rank = values["rank"] as? Int {
            self.coinData[coin]!["rank"] = rank
          }
          if let iconUrl = values["icon_url"] as? String {
            self.coinData[coin]!["iconUrl"] = iconUrl
          }
        }
        
        if GlobalValues.coins.count > 0 {
//          Defaults[.cryptoSymbolNamePairs]
          Defaults[.cryptoSymbolNamePairs] = cryptoSymbolNamePairs
        }
      }
      if !self.favouritesTab {
        self.coins = allCoins
      }
      else {
        // for reorder ability
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
    
    if coins.count > 20 {
      self.pagedArray = PagedArray<String>(count: coins.count, pageSize: 20)
    }
    else {
      self.pagedArray = PagedArray<String>(count: coins.count, pageSize: 2)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !self.favouritesTab {
      FirebaseService.shared.updateScreenName(screenName: "All Dashboard", screenClass: "DashboardViewController")
    }
    else {
      FirebaseService.shared.updateScreenName(screenName: "Favourites Dashboard", screenClass: "FavouritesDashboardViewController")
    }
    
    if currentReachabilityStatus == .notReachable {
      let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
      present(alert, animated: true, completion: nil)
    }
    tableView.reloadData()
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
        let messageLabel = UILabel(frame: .zero)
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
    
    if coins.count > 20 {
      self.pagedArray = PagedArray<String>(count: coins.count, pageSize: 20)
    }
    else {
      self.pagedArray = PagedArray<String>(count: coins.count, pageSize: 2)
    }
    
    headerBackgroundView.isHidden = false
    activityIndicator.stopAnimating()
    tableView.reloadData()
  }
  
//  func setupCoinRefs() {
//
//    for coinRef in coinRefs {
//      coinRef.removeAllObservers()
//    }
//
//    coinRefs = []
//
//    for coin in self.pagedArray {
//      if let coin = coin {
//
//        if coinData[coin] == nil {
//          self.coinData[coin] = [:]
//        }
//        self.coinData[coin]!["currentPrice"] = 0.0
//        self.coinData[coin]!["timestamp"] = 0.0
//        self.coinData[coin]!["volume24hrs"] = 0.0
//        self.coinData[coin]!["percentageChange24hrs"] = 0.0
//        self.coinData[coin]!["priceChange24hrs"] = 0.0
//
//        self.coinRefs.append(self.databaseRef.child(coin).child("Data").child(currency))
//      }
//
//    }
//
//    for coinRef in self.coinRefs {
//      coinRef.observe(.value, with: {(snapshot) -> Void in
//        if let dict = snapshot.value as? [String : AnyObject] {
//          if let index = self.coinRefs.index(of: coinRef) {
//            let coin = self.coins[index]
//            self.changedRow = index
//            self.updateCoinDataStructure(coin: coin, dict: dict)
//          }
//        }
//      })
//    }
//  }
  
  func setupCoinRefs(index: Int) {
    
    if let coin = self.pagedArray[index] {
      if coinData[coin] == nil {
        self.coinData[coin] = [:]
      }
      self.coinData[coin]!["currentPrice"] = 0.0
      self.coinData[coin]!["timestamp"] = 0.0
      self.coinData[coin]!["volume24hrs"] = 0.0
      self.coinData[coin]!["percentageChange24hrs"] = 0.0
      self.coinData[coin]!["priceChange24hrs"] = 0.0
      
      if index < coinRefs.count {
        coinRefs[index].removeAllObservers()
        self.coinRefs[index] = self.databaseRef.child(coin).child("Data").child(currency)
        
        coinRefs[index].observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String : AnyObject] {
            let coin = self.coins[index]
            self.changedRow = index
            self.updateCoinDataStructure(coin: coin, dict: dict)
          }
        })
      }
      else {
        self.coinRefs.append(self.databaseRef.child(coin).child("Data").child(currency))
        
        coinRefs[coinRefs.count-1].observe(.value, with: {(snapshot) -> Void in
          if let dict = snapshot.value as? [String : AnyObject] {
            let coin = self.coins[index]
            self.changedRow = index
            self.updateCoinDataStructure(coin: coin, dict: dict)
          }
        })
      }
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
    if pagedArray != nil {
      return pagedArray.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    loadDataIfNeededForRow(row: indexPath.row)
    
    if favouritesTab {
      if let spacer = tableView.reorder.spacerCell(for: indexPath) {
        return spacer
      }
    }
    
    var coin: String
    if isFiltering() {
      coin = coinSearchResults[indexPath.row]
      
      let coinIndex = coins.index(of: coin)!
      
      loadDataIfNeededForRow(row: coinIndex)
    }
    else {
      if let pagedCoin =  pagedArray[indexPath.row] {
        coin = pagedCoin
      }
      else {
        coin = "BTC"
      }
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
//        cell!.coinPercentageChangeLabel.theme_textColor = GlobalPicker.viewTextColor
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
    
    let destinationPagedCoin = pagedArray[destinationIndexPath.row]
    pagedArray[destinationIndexPath.row] = pagedArray[sourceIndexPath.row]
    pagedArray[sourceIndexPath.row] = destinationPagedCoin
    
    Defaults[.dashboardFavourites] = coins
  }
}


// paged array
extension DashboardViewController {
  
  
  func loadDataIfNeededForRow(row: Int) {
    
    let currentPage = pagedArray.page(for: row)
    if needsLoadDataForPage(currentPage) {
      loadDataForPage(currentPage)
    }
    
    var preloadMargin: Int
    if pagedArray.count > 5 {
      preloadMargin = 5

    }
    else {
      preloadMargin = 0
    }

    let preloadIndex = row + preloadMargin
    if preloadIndex < pagedArray.endIndex {
      let preloadPage = pagedArray.page(for: preloadIndex)
      if preloadPage > currentPage && needsLoadDataForPage(preloadPage) {
        loadDataForPage(preloadPage)
      }
    }
  }
  
  func needsLoadDataForPage(_ page: Int) -> Bool {
    return pagedArray.elements[page] == nil
  }
  
  func loadDataForPage(_ page: Int) {
    let indexes = pagedArray.indexes(for: page)
    let data = Array(coins[indexes])
    self.pagedArray.set(data, forPage: page)
    
    for index in indexes {
      setupCoinRefs(index: index)
    }
//    // Reload cells
//    if let indexPathsToReload = self.visibleIndexPathsForIndexes(indexes) {
//      self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
//    }
    
  }
  
  func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
    return tableView.indexPathsForVisibleRows?.filter { indexes.contains($0.row) }
  }
}



