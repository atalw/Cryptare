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
  
  var coinPairData: [String: Any]!
  var currentPair: (String, String)!
  var currentMarket: (String, String)!
  
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
    vc2.currentPair = currentPair
    vc2.currentMarket = currentMarket
    
    if let marketData = coinPairData[currentMarket.0] as? [String: Any] {
      vc2.exchangePrice = marketData["price"] as? Double
    }
    
    return [vc1, vc2]
  }()
  
  var favouritePairs: [String: [String: [[String: String]]]] = [:]
  var favouriteStatus: Bool = false
  var favouriteButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "\(currentPair.0)/\(currentPair.1)"
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
    setFavouriteButtonStatus()
  }
  
  func getFavouritePairsList() {
    if let favouritePairs = Defaults[.favouritePairs] as? [String: [String: [[String: String]]]] {
      self.favouritePairs = favouritePairs
    }
    
  }
  
  func setFavouriteButtonStatus() {
    if doesFavouritePairsContain(pair: currentPair, market: currentMarket.0) {
      var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
      image = image?.maskWithColor(color: selectedColour)
      favouriteButton.image = image
      favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
      self.navigationItem.rightBarButtonItem = favouriteButton
      favouriteStatus = true
      return
    }
    var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
    image = image?.maskWithColor(color: UIColor.gray)
    favouriteButton.image = image
    favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
    self.navigationItem.rightBarButtonItem = favouriteButton
    favouriteStatus = false
    
  }
  
  @objc func favouriteButtonTapped() {
    
    let doesContain = doesFavouritePairsContain(pair: currentPair, market: currentMarket.0)
    let coin = currentPair.0
    let pair = currentPair.1
    let market = currentMarket.0
    if favouriteStatus {
      if !doesContain {
        favouriteStatus = false
      } else {
        
        if var pairArray = favouritePairs[coin]![pair] {
          if pairArray.count < 2 {
            favouritePairs[coin]![pair] = nil
          }
          else {
            for index in 0..<pairArray.count {
              if market == pairArray[index]["name"] {
                pairArray.remove(at: index)
                break
              }
            }
            favouritePairs[coin]![pair] = pairArray
          }
        }
        favouriteStatus = false
      }
    } else {
      if doesContain {
        favouriteStatus = false
      }
      else {
        if favouritePairs[coin] == nil {
          favouritePairs[coin] = [:]
        }
        
        if favouritePairs[coin]![pair] == nil {
          favouritePairs[coin]![pair] = []
        }
        
        let data = ["name": currentMarket.0, "databaseTitle": currentMarket.1]
        favouritePairs[coin]![pair]?.append(data)
        favouriteStatus = true
      }
    }
    
    Defaults[.favouritePairs] = favouritePairs
    setFavouriteButtonStatus()
    
  }
  
  func doesFavouritePairsContain(pair: (String, String), market: String) -> Bool {
    if let data = favouritePairs[pair.0] {
      if let pairArray = data[pair.1] {
        for element in pairArray {
          if market == element["name"] {
            return true
          }
        }
      }
    }
    return false
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
