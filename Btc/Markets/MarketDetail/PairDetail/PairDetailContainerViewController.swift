//
//  PairDetailContainerViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Parchment
import SwiftyUserDefaults

class PairDetailContainerViewController: UIViewController {
  
  let selectedColour = UIColor.init(hex: "#F7B54A")
  
  var coinPair: [String: Any]!
  var currentPair: (String, String)!
  var currentMarket: [String: String]!
  
  var detailVC: PairDetailViewController!
  var alertVC: PairAlertViewController!
  
  let pagingViewController = PagingViewController<PagingIndexItem>()
  
  lazy var viewControllerList: [UIViewController] = {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let vc1 = storyboard.instantiateViewController(withIdentifier: "PairDetailViewController") as! PairDetailViewController
    self.detailVC = vc1
    vc1.parentController = self
    vc1.title = "Details"

    let vc2 = storyboard.instantiateViewController(withIdentifier: "PairAlertViewController") as! PairAlertViewController
    self.alertVC = vc2
    vc2.parentController = self
    vc2.title = "Alerts"

    return [vc1, vc2]
  }()
  
  var favouritePairs: [String: Any] = [:]
  var favouriteStatus: Bool = false
  var favouriteButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "CoinPair"
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    let image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
    favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
    self.navigationItem.rightBarButtonItem = favouriteButton
    
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
    
    getFavouritePairsList()
//    setFavouriteButtonStatus()
  }
  
  func getFavouritePairsList() {
    favouritePairs = Defaults[.favouritePairs]
  }
  
  func setFavouriteButtonStatus() {
    if let baseData = favouritePairs[currentPair.0] as? [String: Any] {
      if let market = baseData[currentPair.1] as? [String: String] {
        if market == currentMarket {
          var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
          image = image?.maskWithColor(color: selectedColour)
          favouriteButton.image = image
          favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
          self.navigationItem.rightBarButtonItem = favouriteButton
          favouriteStatus = true
          return
        }
      }
    }
    var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
    image = image?.maskWithColor(color: UIColor.gray)
    favouriteButton.image = image
    favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
    self.navigationItem.rightBarButtonItem = favouriteButton
    favouriteStatus = false
    
  }
  
  @objc func favouriteButtonTapped() {
    
//    if favouriteStatus {
//      if !favouritePairs.contains(currentPair) {
//        favouriteStatus = false
//      } else {
//        for index in 0..<favouritePairs.count {
//          if currentPair == favouritePairs[index] {
//            favouritePairs.remove(at: index)
//            break
//          }
//        }
//        favouriteStatus = true
//      }
//    } else {
//      if favouritePairs.contains(currentPair) {
//        favouriteStatus = false
//      }
//      else {
//        favouritePairs.append(currentPair)
//        favouriteStatus = true
//
//      }
//    }
    
    Defaults[.favouritePairs] = favouritePairs
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

extension PairDetailContainerViewController: PagingViewControllerDataSource {
  
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

extension PairDetailContainerViewController: PagingViewControllerDelegate {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
    
    //    if let index = viewControllerList.index(of: destinationViewController) {
    //      self.currentSelectedIndex = index
    //    }
  }
  
}
