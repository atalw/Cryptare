//
//  MainViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import SwiftyUserDefaults
import Parchment

class MainViewController: UIViewController {
  
  lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.placeholder = "Search"
    
    definesPresentationContext = true
    searchController.searchBar.searchBarStyle = .minimal
    searchController.searchBar.barStyle = .default
    searchController.searchResultsUpdater =  self
    return searchController
  }()
  
  var dashboardVC: DashboardViewController!
//  var favouritesVC: DashboardViewController!
  
  let pagingViewController = PagingViewController<PagingIndexItem>()
  var currentSelectedIndex: Int! = 0
  
  var currency: String!
  
  @IBOutlet weak var currencyButton: UIBarButtonItem!
  
  @IBAction func currencyButtonTapped(_ sender: Any) {
    let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
    let selectCurrencyController = settingsStoryboard.instantiateViewController(withIdentifier: "CountrySelectionViewController")
    self.present(selectCurrencyController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    let introComplete = Defaults[.mainAppIntroComplete]
    
    if !introComplete {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let introViewController = storyboard.instantiateViewController(withIdentifier: "AppIntroViewController") as! AppIntroViewController
      introViewController.fromAppDelegate = true
      
      self.present(introViewController, animated: true, completion: nil)
    }
   

    if #available(iOS 11.0, *) {
      navigationItem.hidesSearchBarWhenScrolling = false
      navigationItem.searchController = searchController
    }
    
    if #available(iOS 9.1, *) {
      searchController.obscuresBackgroundDuringPresentation = false
    }
    
    
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
    
    let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
    dashboardVC = dashboardStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
    dashboardVC.favouritesTab = false
    dashboardVC.title = "All"
    dashboardVC.parentController = self
    
//    containerView.
    addChildViewController(dashboardVC)
    self.view.addSubview(dashboardVC.view)
    
    dashboardVC.view.frame = view.bounds
    dashboardVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // tell the childviewcontroller it's contained in it's parent
    dashboardVC.didMove(toParentViewController: self)

//    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    if GlobalValues.currency != nil {
      currency = GlobalValues.currency!
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if GlobalValues.currency == nil {
      currency = "USD"
      GlobalValues.currency = "USD"
      Defaults[.selectedCountry] = "usa"
    }
    
    currencyButton.title = GlobalValues.currency
    
    if currency != GlobalValues.currency! {
      currency = GlobalValues.currency!
      
      dashboardVC.currency = currency
    }
    dashboardVC.loadAllCoinData()
    
    guard (dashboardVC.tableView) != nil else { return }
    if let selectedTableIndex = dashboardVC.tableView.indexPathForSelectedRow {
      dashboardVC.deselectTableRow(indexPath: selectedTableIndex)
    }
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let destinationVC = segue.destination
    if let dashboardVC = destinationVC as? DashboardViewController {
      dashboardVC.parentController = self
    }
  }

  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    dashboardVC.coinSearchResults = dashboardVC.coins.filter( {( coin: String ) -> Bool in
      var coinName: String = coin
      for (symbol, name) in GlobalValues.coins {
        if symbol == coin {
          coinName = name
        }
      }
      if coin.lowercased().contains(searchText.lowercased()) ||
        coinName.lowercased().contains(searchText.lowercased()) {
        return true
      }
      else { return false }
    })
    
    dashboardVC.tableView.reloadData()
  }
}

extension MainViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}

extension MainViewController: SlideMenuControllerDelegate {
  
  func leftWillOpen() {
    //        print("SlideMenuControllerDelegate: leftWillOpen")
  }
  
  func leftDidOpen() {
    //        print("SlideMenuControllerDelegate: leftDidOpen")
  }
  
  func leftWillClose() {
    //        print("SlideMenuControllerDelegate: leftWillClose")
  }
  
  func leftDidClose() {
    //        print("SlideMenuControllerDelegate: leftDidClose")
  }
  
  func rightWillOpen() {
    //        print("SlideMenuControllerDelegate: rightWillOpen")
  }
  
  func rightDidOpen() {
    //        print("SlideMenuControllerDelegate: rightDidOpen")
  }
  
  func rightWillClose() {
    //        print("SlideMenuControllerDelegate: rightWillClose")
  }
  
  func rightDidClose() {
    //        print("SlideMenuControllerDelegate: rightDidClose")
  }
}

