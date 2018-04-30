//
//  AddCoinTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 27/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class AddCoinTableViewController: UITableViewController {
  
  var parentController: UIViewController!
  
  var isAddAlertVc: Bool! = false
  
  var coins: [(String, String)] = []
  var currencies: [(String, String)] = []
  
  var coinSearchResults = [(String, String)]()
  var currencySearchResults = [(String, String)]()
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    FirebaseService.shared.updateScreenName(screenName: "Add Coin", screenClass: "AddCoinViewController")

    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    if (parentController as? AddPairAlertTableViewController) != nil {
      isAddAlertVc = true
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    searchController.searchResultsUpdater = self
    
    if #available(iOS 9.1, *) {
      searchController.obscuresBackgroundDuringPresentation = false
    } else {
      // Fallback on earlier versions
    }
    searchController.searchBar.placeholder = "Search"
    
    if #available(iOS 11.0, *) {
      navigationItem.searchController = searchController
      navigationItem.hidesSearchBarWhenScrolling = true
      
    } else {
      // Fallback on earlier versions
    }
    
    definesPresentationContext = true
    searchController.searchBar.searchBarStyle = .minimal
    
    let scb = searchController.searchBar
    scb.theme_tintColor = GlobalPicker.searchTintColor
    scb.theme_barTintColor = GlobalPicker.searchBarTintColor
    
    if let textfield = scb.value(forKey: "searchField") as? UITextField {
      textfield.theme_textColor = GlobalPicker.searchBarTextColor
      if let backgroundview = textfield.subviews.first {
        
        // Background color
        backgroundview.theme_backgroundColor = GlobalPicker.searchBarBackgroundColor
        
        // Rounded corner
        backgroundview.layer.cornerRadius = 10;
        backgroundview.clipsToBounds = true;
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if #available(iOS 11.0, *) {
      navigationItem.hidesSearchBarWhenScrolling = false
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if #available(iOS 11.0, *) {
      navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    self.coins = GlobalValues.coins
    
    for country in GlobalValues.countryList {
      self.currencies.append((country.1, country.3))
    }
    self.tableView.reloadData()
    
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
  
  func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    coinSearchResults = coins.filter( {( arg0 ) -> Bool in
      let (coin, name) = arg0
      if coin.lowercased().contains(searchText.lowercased()) || name.lowercased().contains(searchText.lowercased()) {
        return true
      }
      else { return false }
    })
    
    currencySearchResults = currencies.filter( {( arg0 ) -> Bool in
      let (currency, name) = arg0
      if currency.lowercased().contains(searchText.lowercased()) || name.lowercased().contains(searchText.lowercased()) {
        return true
      }
      else { return false }
    })
    
    tableView.reloadData()
  }



// MARK: - Table view data source

override func numberOfSections(in tableView: UITableView) -> Int {
  if isAddAlertVc {
    return 1
  }
  return 2
}

override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
  if isAddAlertVc {
    return "Cryptocurrencies"
  }
  if section == 0 {
    return "Fiat Currencies"
  }
  else if section == 1 {
    return "Cryptocurrencies"
  }
  return "Fiat Currencies"
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
  if isAddAlertVc {
    if isFiltering() { return coinSearchResults.count }
    return coins.count
  }
  
  if isFiltering() {
    if section == 0 {
      return currencySearchResults.count
    }
    if section == 1 {
      return coinSearchResults.count
    }
  }
  if section == 0 {
    return self.currencies.count
  }
  if section == 1 {
    return self.coins.count
  }
  return 0
}

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(withIdentifier: "addCoinCell", for: indexPath) as! AddCoinTableViewCell
  cell.selectionStyle = .none
  var data: (String, String) = ("", "")
  let section = indexPath.section
  
  if isAddAlertVc {
    if isFiltering() {
      data = coinSearchResults[indexPath.row]
    }
    else {
      data = coins[indexPath.row]
    }
    
    cell.coinImage.loadSavedImage(coin: data.0)

  }
  else {
    if isFiltering() {
      if section == 0 {
        data = currencySearchResults[indexPath.row]
      }
      if section == 1 {
        data = coinSearchResults[indexPath.row]
      }
    }
    else {
      if section == 0 {
        data = currencies[indexPath.row]
      }
      else {
        data = coins[indexPath.row]
      }
    }
    
    if section == 0 {
      cell.coinImage.image = UIImage(named: data.0.lowercased())
    }
    else {
      cell.coinImage.loadSavedImage(coin: data.0)
    }
  }
  
  cell.coinNameLabel.text = data.1
  cell.coinSymbolLabel.text = "(\(data.0))"
  
  return cell
}

override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  var coin: String!
  let section = indexPath.section
  
  if isAddAlertVc {
    if isFiltering() { coin = coinSearchResults[indexPath.row].0 }
    else { coin = coins[indexPath.row].0 }
  }
  else {
    if isFiltering() {
      if section == 0 {
        coin = currencySearchResults[indexPath.row].0
        
      }
      else if section == 1 {
        coin = coinSearchResults[indexPath.row].0
      }
    }
    else {
      if section == 0 {
        coin = currencies[indexPath.row].0
      }
      else if section == 1 {
        coin = coins[indexPath.row].0
      }
    }
  }
  
  
  if let portfolioSummaryVc = parentController as? PortfolioSummaryViewController {
    self.navigationController?.popViewController(animated: true)

    if section == 0 {
      portfolioSummaryVc.newCurrencyAdded(currency: coin)
      
    }
    else if section == 1 {
      portfolioSummaryVc.newCoinAdded(coin: coin)
    }
  }
  else if let addPairTableVc = parentController as? AddPairAlertTableViewController {
    addPairTableVc.getTradingPairs(coin: coin)

    self.dismiss(animated: true, completion: nil)
  }
  
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


/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

}

extension AddCoinTableViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
