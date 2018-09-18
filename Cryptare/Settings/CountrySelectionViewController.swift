//
//  CountrySelectionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 26/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class CountrySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var tableViewController : countryTableViewController!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var selectCountryTitleLabel: UILabel! {
    didSet {
      selectCountryTitleLabel.adjustsFontSizeToFitWidth = true
      selectCountryTitleLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  @IBAction func closeButtonPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  var sortedCountryList: [(String, String, String, String)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    self.tableViewController.countryTable.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableViewController.countryTable.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    sortedCountryList = GlobalValues.countryList.sorted(by: {$0.1 < $1.1})
    
    tableViewController.countryTable.delegate = self
    tableViewController.countryTable.dataSource = self
    tableViewController.countryTable.tableFooterView = UIView(frame: .zero)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseService.shared.updateScreenName(screenName: "Currency Selection", screenClass: "CountrySelectionViewController")

  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let tableViewController = segue.destination as? countryTableViewController {
      self.tableViewController = tableViewController
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
//    return 2
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    if section == 0 {
//      return "Cryptocurrencies"
//    }
//    else {
//      return "Fiat currencies"
//    }
    
    return "Fiat currencies"

  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if section == 0 {
//      return 1
//    }
//    else {
//      return sortedCountryList.count
//    }
    
    return sortedCountryList.count

  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    let section = indexPath.section
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! AddCoinTableViewCell
    cell.selectionStyle = .none
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
//    if section == 0 {
//      cell.coinImage.image = UIImage.init(named: "btc")
//      cell.coinNameLabel.text = "Bitcoin"
//      cell.coinSymbolLabel.text = "BTC"
//    }
//    else if section == 1 {
//      cell.coinImage.image = UIImage.init(named: sortedCountryList[row].1.lowercased())
//      cell.coinNameLabel.text = sortedCountryList[row].3
//      cell.coinSymbolLabel.text = "(\(sortedCountryList[row].1))"
//    }
    
    cell.coinImage.image = UIImage.init(named: sortedCountryList[row].1.lowercased())
    cell.coinNameLabel.text = sortedCountryList[row].3
    cell.coinSymbolLabel.text = "(\(sortedCountryList[row].1))"
    
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let row = indexPath.row
    let section = indexPath.section
    
//    if section == 0 {
//      Defaults[.selectedCountry] = sortedCountryList[row].0
//      GlobalValues.currency = "BTC"
//    }
//    else if section == 1 {
//      Defaults[.selectedCountry] = sortedCountryList[row].0
//      GlobalValues.currency = sortedCountryList[row].1
//    }
    
    Defaults[.selectedCountry] = sortedCountryList[row].0
    GlobalValues.currency = sortedCountryList[row].1
    FirebaseService.shared.currency_selected(currency: GlobalValues.currency)
    
    self.dismiss(animated: true, completion: nil)
    
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

class countryTableViewController: UITableViewController {
  
  @IBOutlet var countryTable: UITableView!
}
