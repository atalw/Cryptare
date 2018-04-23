//
//  MarketsContainerViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 20/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Parchment
import SwiftyUserDefaults

class MarketsContainerViewController: UIViewController {
  
  // for testing------------------------------------
  let testingFavouritePairs = [
    "BTC" : [
      "INR": [
        [
          "name": "Koinex",
          "databaseTitle": "koinex/BTC/INR"
        ],
        [
          "name": "WazirX",
          "databaseTitle": "wazirx/BTC/INR"
        ]
      ],
      "ETH" : [ [
        "name": "Binance",
        "databaseTitle": "binance/BTC/ETH"
        ] ]
    ],
    "ETH" : [
      "USD" : [ [
        "name": "Coinbase",
        "databaseTitle" : "coinbase/ETH/USD"
        ] ]
    ]
  ]
  //------------------------------------------------
  
  var marketsVC: MarketsViewController!
  var favouritesVC: MarketsViewController!
  
  let pagingViewController = PagingViewController<PagingIndexItem>()
  
  lazy var viewControllerList: [UIViewController] = {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let vc1 = storyboard.instantiateViewController(withIdentifier: "MarketsViewController") as! MarketsViewController
    vc1.favouritesTab = false
    vc1.title = "All"
    self.marketsVC = vc1
    vc1.parentController = self
    
    let vc2 = storyboard.instantiateViewController(withIdentifier: "FavouritesMarketsViewController") as! MarketsViewController
    vc2.favouritesTab = true
    vc2.title = "Favourites"
    self.favouritesVC = vc2
    vc2.parentController = self
    
    return [vc2, vc1]
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // for testing-------------------------------------------
//    Defaults[.favouritePairs] = testingFavouritePairs
//    print(Defaults[.favouritePairs])
    // --------------------------------------------------------
    
    self.title = "Markets"
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    
    pagingViewController.view.theme_backgroundColor = GlobalPicker.navigationBarTintColor
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
    if let favouritesVC = viewControllerList.first as? MarketsViewController {
      favouritesVC.resetFavourites()
      favouritesVC.getFavourites()
    }
    
    for viewController in viewControllerList {
      if let marketVC = viewController as? MarketsViewController {
        guard (marketVC.tableView) != nil else { return }
        if let selectedTableIndex = marketVC.tableView.indexPathForSelectedRow {
          marketVC.deselectTableRow(indexPath: selectedTableIndex)
        }
      }
    }
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


extension MarketsContainerViewController: PagingViewControllerDataSource {
  
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

extension MarketsContainerViewController: PagingViewControllerDelegate {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
    
//    if let index = viewControllerList.index(of: destinationViewController) {
//      self.currentSelectedIndex = index
//    }
  }
  
}
