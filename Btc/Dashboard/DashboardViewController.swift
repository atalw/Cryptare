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
    
    @IBOutlet weak var tableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var listOfCoins: DatabaseReference!
    var coinRefs: [DatabaseReference] = []
    
//    let searchController = UISearchController(searchResultsController: nil)
    var coinSearchResults = [String]()

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var header24hrChangeLabel: UILabel!
    @IBOutlet weak var headerCurrentPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
        tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        rankLabel.theme_textColor = GlobalPicker.viewAltTextColor
        header24hrChangeLabel.theme_textColor = GlobalPicker.viewAltTextColor
        headerCurrentPriceLabel.theme_textColor = GlobalPicker.viewAltTextColor
        
        ThemeManager.setTheme(index: Defaults[.currentThemeIndex])
        
        self.currency = GlobalValues.currency!
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        databaseRef = Database.database().reference()
        
        listOfCoins = databaseRef.child("coins")
        
        if !favouritesTab {
            listOfCoins.queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: AnyObject] {
                    let sortedDict = dict.sorted(by: { ($0.1["rank"] as! Int) < ($1.1["rank"] as! Int)})
                    self.coins = []
                    GlobalValues.coins = []
                    self.tableView.reloadData()
                    for index in 0..<sortedDict.count {
                        self.coins.append(sortedDict[index].key)
                        GlobalValues.coins.append((sortedDict[index].key, sortedDict[index].value["name"] as! String))
                    }
                    self.setupCoinRefs()
                }
            })
        }
        else {
            // for reorder ability
            tableView.reorder.delegate = self
        }
        
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
            //            self.present(alert, animated: true){}
            present(alert, animated: true, completion: nil)
        }
        
        loadAllCoinData()
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
        print("dis")
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
                messageLabel.textColor = UIColor.black
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center
                messageLabel.sizeToFit()
                
                tableView.backgroundView = messageLabel
            }
            else {
                tableView.backgroundView = nil
            }
        }
        
        self.setupCoinRefs()
    }
    
    
    func setupCoinRefs() {
        coinData = [:]
        for coin in self.coins {
            self.coinData[coin] = [:]
            self.coinData[coin]!["rank"] = 0
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
            self.coinRefs.append(self.databaseRef.child(coin))
        }
        
        for coinRef in self.coinRefs {
            coinRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    if let index = self.coinRefs.index(of: coinRef) {
                        let coin = self.coins[index]
                        self.changedRow = index
                        self.updateCoinDataStructure(coin: coin, dict: dict)
                    }
                }
                    
            })
            
            coinRef.observe(.childChanged, with: {(snapshot) -> Void in
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
        self.coinData[coin]!["rank"] = dict["rank"] as! Int
        self.coinData[coin]!["iconUrl"] = dict["icon_url"] as! String

        if let currencyData = dict[self.currency] as? [String: Any] {
            if self.coinData[coin]!["oldPrice"] == nil {
                self.coinData[coin]!["oldPrice"] = 0.0
            }
            else {
                self.coinData[coin]!["oldPrice"] = self.coinData[coin]!["currentPrice"]
            }
            self.coinData[coin]!["currentPrice"] = currencyData["price"] as! Double
            self.coinData[coin]!["volume24hrs"] = currencyData["vol_24hrs_currency"]
            let percentage = currencyData["change_24hrs_percent"] as! Double
            let roundedPercentage = Double(round(1000*percentage)/1000)
            self.coinData[coin]!["percentageChange24hrs"] = roundedPercentage
            self.coinData[coin]!["priceChange24hrs"] = currencyData["change_24hrs_fiat"] as! Double
            self.coinData[coin]!["timestamp"] = currencyData["timestamp"] as! Double
            self.tableView.reloadData()
        }
        
    }
    
    func isFiltering() -> Bool {
        return parentController.searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return parentController.searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination
        if let graphController = destinationViewController as? GraphViewController {
            //            graphController.parentControler = self
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
        
        if let rank = self.coinData[coin]?["rank"] as? Int {
            cell!.coinRank.text = "\(rank)"
            cell!.coinRank.adjustsFontSizeToFitWidth = true
        }
        
        cell!.coinSymbolLabel.text = coin
        cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
        
        if let urlString = self.coinData[coin]?["iconUrl"] as? String {
            cell!.coinSymbolImage.loadSavedImageWithURL(coin: coin, urlString: urlString)
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
                colour = UIColor.black
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
                cell!.coinPercentageChangeLabel.textColor = UIColor.black
                colour = UIColor.black
            }
            
            if let priceChange = self.coinData[coin]?["priceChange24hrs"] as? Double {
                cell!.coinPriceChangeLabel.text = priceChange.asCurrency
                cell!.coinPriceChangeLabel.adjustsFontSizeToFitWidth = true
                cell!.coinPriceChangeLabel.textColor = colour
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "graphViewController") as! GraphViewController
        if isFiltering() {
            targetViewController.databaseTableTitle = self.coinSearchResults[indexPath.row]
        }
        else {
            targetViewController.databaseTableTitle = self.coins[indexPath.row]
        }
        self.navigationController?.pushViewController(targetViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        
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




