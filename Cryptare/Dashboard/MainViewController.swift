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
  var favouritesVC: DashboardViewController!
  
  let pagingViewController = PagingViewController<PagingIndexItem>()
  var currentSelectedIndex: Int! = 0
  
  var currency: String!
  
  lazy var viewControllerList: [UIViewController] = {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let vc1 = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
    vc1.favouritesTab = false
    vc1.title = "All"
    self.dashboardVC = vc1
    vc1.parentController = self
    
    let vc2 = storyboard.instantiateViewController(withIdentifier: "FavouriteDashboardViewController") as! DashboardViewController
    vc2.favouritesTab = true
    vc2.title = "Favourites"
    self.favouritesVC = vc2
    vc2.parentController = self
    
    let favouriteFirstDefaults = Defaults[.dashboardFavouritesFirstTab]
    
    return favouriteFirstDefaults ? [vc2, vc1] : [vc1, vc2]
  }()
  
  
  @IBOutlet weak var currencyButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
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
    
//    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    if GlobalValues.currency != nil {
      currency = GlobalValues.currency!
    }
    
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    
    pagingViewController.collectionViewLayout.collectionView?.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    
    
    pagingViewController.indicatorColor = UIColor.init(hex: "ff7043")
    pagingViewController.textColor = UIColor.lightGray
    pagingViewController.selectedTextColor = UIColor.white
    
    pagingViewController.indicatorOptions = .visible(
      height: 4,
      zIndex: Int.max,
      spacing: UIEdgeInsets.zero,
      insets: UIEdgeInsets.zero)
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if GlobalValues.currency == nil {
      currency = "USD"
      GlobalValues.currency = "USD"
      Defaults[.selectedCountry] = "usa"
    }
    
    currencyButton.title = currency!
    
    
    for (_, viewController) in viewControllerList.enumerated() {
      if let dashboardVC = viewController as? DashboardViewController {
        guard (dashboardVC.tableView) != nil else { return }
        if let selectedTableIndex = dashboardVC.tableView.indexPathForSelectedRow {
          dashboardVC.deselectTableRow(indexPath: selectedTableIndex)
        }
      }
    }
    
    if currency != GlobalValues.currency! {
      currency = GlobalValues.currency!
      
      for (index, viewController) in viewControllerList.enumerated() {
        if let dashboardVC = viewController as? DashboardViewController {
          dashboardVC.currency = currency
          
          guard let currentIndex = currentSelectedIndex else { return }
          
          if index == currentIndex {
            dashboardVC.loadAllCoinData()
          }
        }
      }
    }
    else {
      guard let currentIndex = currentSelectedIndex else { return }
      (viewControllerList[currentIndex] as? DashboardViewController)?.loadAllCoinData()
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
    
    favouritesVC.coinSearchResults = favouritesVC.coins.filter( {( coin: String ) -> Bool in
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
    favouritesVC.tableView.reloadData()
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


extension MainViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return PagingIndexItem(index: index, title: viewControllerList[index].title ?? "") as! T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return viewControllerList[index]
  }
  
  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return viewControllerList.count
  }
  
}

extension MainViewController: PagingViewControllerDelegate {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
    
    if let index = viewControllerList.index(of: destinationViewController) {
      self.currentSelectedIndex = index
    }
  }
  
}

//extension MainViewController: GADBannerViewDelegate {
//  /// Tells the delegate an ad request loaded an ad.
//  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//    print("adViewDidReceiveAd")
//  }
//
//  /// Tells the delegate an ad request failed.
//  func adView(_ bannerView: GADBannerView,
//              didFailToReceiveAdWithError error: GADRequestError) {
//    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
//  }
//
//  /// Tells the delegate that a full-screen view will be presented in response
//  /// to the user clicking on an ad.
//  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//    print("adViewWillPresentScreen")
//  }
//
//  /// Tells the delegate that the full-screen view will be dismissed.
//  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
//    print("adViewWillDismissScreen")
//  }
//
//  /// Tells the delegate that the full-screen view has been dismissed.
//  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
//    print("adViewDidDismissScreen")
//  }
//
//  /// Tells the delegate that a user click will open another app (such as
//  /// the App Store), backgrounding the current app.
//  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
//    print("adViewWillLeaveApplication")
//  }
//}


