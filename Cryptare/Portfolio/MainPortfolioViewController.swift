//
//  MainPortfolioViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 24/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Parchment
import SwiftyUserDefaults
import FirebaseAuth
import FirebaseDatabase
import Armchair
import AZDropdownMenu

class MainPortfolioViewController: UIViewController {
  
  // dev-------------------------------
  let portfolioEntries: [[Int:Any]] = [
    [4: 798436.43, 2: 1, 0: "BTC", 3: "2018-01-28", 1: "buy"],
    [4: 900000, 2: 0.5, 0: "BTC", 3: "2018-02-28", 1: "sell"],
    [4: 11000, 2: 5, 0: "LTC", 3: "2017-12-28", 1: "buy"],
    [4: 12000, 2: 2, 0: "LTC", 3: "2018-01-28", 1: "sell"],
    [4: 24000, 2: 2, 0: "ETH", 3: "2017-12-28", 1: "buy"]
  ]
  // ------------------------------------
  
  var currency: String!
  
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  
  let pagingViewController = PagingViewController<PagingIndexItem>()
  
  lazy var viewControllerList: [UIViewController] = {
    return []
  }()
  
  var portfolioNames: [String]!
  var currentSelectedIndex: Int = 0
  
  let dropDownTitles = ["Add a coin", "Add a portfolio"]
  
  var menu: AZDropdownMenu!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menu = AZDropdownMenu(titles: dropDownTitles)
    menu.itemFontName = UIFont.systemFont(ofSize: 17, weight: .semibold).fontName
    menu.itemFontSize = 17
//    menu.itemFont
    
    let introComplete = Defaults[.mainPortfolioIntroComplete]
    
    if !introComplete {
      let introViewController = storyboard?.instantiateViewController(withIdentifier: "PortfolioIntroViewController") as! PortfolioIntroViewController
      
      self.navigationController?.present(introViewController, animated: true, completion: nil)
    }
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
//    let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
//    UserDefaults.standard.set(newData, forKey: "portfolioEntries")
//
//    UserDefaults.standard.remove("fiatPortfolioEntries")
    
    currency = GlobalValues.currency!
    
    dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
    dateFormatter.timeZone = TimeZone.current
    
    timeFormatter.dateFormat = "hh:mm a"
    timeFormatter.timeZone = TimeZone.current
    
    updateOldFormatPortfolioEntries()
    
//    self.title = "Portfolio"
//    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    
    pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 40)
    pagingViewController.menuHorizontalAlignment = .center
    
    pagingViewController.view.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    pagingViewController.collectionViewLayout.collectionView?.theme_backgroundColor = GlobalPicker.navigationBarTintColor
    pagingViewController.indicatorColor = UIColor.init(hex: "ff7043")
    pagingViewController.textColor = UIColor.lightGray
    pagingViewController.selectedTextColor = UIColor.white
    
    pagingViewController.indicatorOptions = .visible(
      height: 4,
      zIndex: Int.max,
      spacing: UIEdgeInsets.zero,
      insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
    
    if FirebaseService.shared.uid != nil {
      let uid = FirebaseService.shared.uid!
      let portfolioRef = Database.database().reference().child("portfolios").child(uid)
      portfolioRef.keepSynced(true)
      portfolioRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
        if !snapshot.exists() {
          let portfolioData: [String: Any] = ["CryptoData": Defaults[.cryptoPortfolioData],
                                              "FiatData": Defaults[.fiatPortfolioData],
                                              "Names": Defaults[.portfolioNames]]
          
          portfolioRef.updateChildValues(portfolioData, withCompletionBlock: { (err, ref) in
            if err != nil {
              print(err ?? "firebase update protfolio error")
              return
            }
          })
        }
        else {
          if let portfolio = snapshot.value as? [String: AnyObject] {
            if let cryptoData = portfolio["CryptoData"] as? [String: Any] {
              Defaults[.cryptoPortfolioData] = cryptoData
            }
            if let fiatData = portfolio["FiatData"] as? [String: Any] {
              Defaults[.fiatPortfolioData] = fiatData
            }
            if let names = portfolio["Names"] as? [String] {
              Defaults[.portfolioNames] = names
            }
          }
        }
      })
      
      self.viewControllerList = self.getPortfolios()
      self.pagingViewController.reloadData()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    for (_, viewController) in viewControllerList.enumerated() {
      if let portfolioVC = viewController as? PortfolioSummaryViewController {
        guard (portfolioVC.tableView) != nil else { return }
        
        if let selectedTableIndex = portfolioVC.tableView.indexPathForSelectedRow{
          portfolioVC.tableView.deselectRow(at: selectedTableIndex, animated: true)
        }
      }
    }
    
    
    
    if currency != GlobalValues.currency! {
      currency = GlobalValues.currency!
      for (_, viewController) in viewControllerList.enumerated() {
        if let summaryVC = viewController as? PortfolioSummaryViewController {
          summaryVC.updateCurrency(currency: currency)
        }
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Armchair.showPromptIfNecessary()
    
    menu.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
      if indexPath.row == 0 {
        if let addCoinViewController = self?.storyboard?.instantiateViewController(withIdentifier: "AddCoinTableViewController") as? AddCoinTableViewController {
          guard let currentIndex = self?.currentSelectedIndex else { return }
          if let currentSelectedVC = self?.viewControllerList[currentIndex] as? PortfolioSummaryViewController {
            addCoinViewController.parentController = currentSelectedVC
              self?.navigationController?.pushViewController(addCoinViewController, animated: true)
          }
          
        }
      }
      if indexPath.row == 1 {
        if let addPortfolioViewController = self?.storyboard?.instantiateViewController(withIdentifier: "addPortfolioViewController") as? AddPortfolioViewController {
          addPortfolioViewController.parentController = self
          self?.navigationController?.pushViewController(addPortfolioViewController, animated: true)
        }
      }
    }
  }
  
  func updateOldFormatPortfolioEntries() {
    if let data = UserDefaults.standard.data(forKey: "portfolioEntries") {
      var portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int:Any]]
      
      var data: [String: [String: [[String: Any]] ]] = [:]
      // create Main portfolio key
      data["Main"] = [:]
      
      for index in 0..<portfolioEntries.count {
        if portfolioEntries[index].count == 5 {
          let firstElement = portfolioEntries[index][0] as? String
          let secondElement = portfolioEntries[index][1] as? String
          let thirdElement = portfolioEntries[index][2] as? Double
          let fourthElement = portfolioEntries[index][3] as? String
          let fifthElement = portfolioEntries[index][4] as? Double
          
          if let coin = firstElement, let type = secondElement, let amountOfCoins = thirdElement, let string = fourthElement, let costPerCoin = fifthElement {
            
            let tradingPair = GlobalValues.currency!
            let exchange = "None"
            let fees = 0.0
            
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            let date = dateFormatter.date(from: "\(string) 12:00 AM")
            
            let dateString = dateFormatter.string(from: date!)
            if data["Main"]![coin] == nil {
              data["Main"]![coin] = []
            }
            
            let totalCost = (costPerCoin * amountOfCoins) - fees
            
            var totalCostUsd: Double!
            if tradingPair == "USD" {
              totalCostUsd = totalCost
              let transaction: [String : Any] = ["type": type,
                                                 "tradingPair": tradingPair,
                                                 "exchange": exchange,
                                                 "exchangeDbTitle" : "MarketAverage",
                                                 "costPerCoin": costPerCoin,
                                                 "amountOfCoins": amountOfCoins,
                                                 "fees": fees,
                                                 "totalCost": totalCost,
                                                 "fiat": tradingPair,
                                                 "totalCostUsd": totalCostUsd,
                                                 "date": dateString]
              data["Main"]![coin]!.append(transaction)
            }
            else {
              getExchangeRateUSD(symbol: tradingPair).then { rate in
                totalCostUsd = totalCost*rate
                
                let transaction: [String : Any] = ["type": type,
                                                   "tradingPair": tradingPair,
                                                   "exchange": exchange,
                                                   "exchangeDbTitle" : "MarketAverage",
                                                   "costPerCoin": costPerCoin,
                                                   "amountOfCoins": amountOfCoins,
                                                   "fees": fees,
                                                   "totalCost": totalCost,
                                                   "fiat": tradingPair,
                                                   "totalCostUsd": totalCostUsd,
                                                   "date": dateString]
                data["Main"]![coin]!.append(transaction)
                Defaults[.cryptoPortfolioData] = data
              }
            }
          }
        }
      }
      Defaults[.cryptoPortfolioData] = data
      Defaults[.portfolioNames] = ["Main"]
    }
  }
  
  @IBAction func addPortfolioButtonTapped(_ sender: Any) {
    
    if (self.menu?.isDescendant(of: self.view) == true) {
      self.menu?.hideMenu()
    } else {
      self.menu?.showMenuFromView(self.view)
    }
  }
  
  func getPortfolios() -> [UIViewController] {
    
    let storyboard = UIStoryboard(name: "Portfolio", bundle: nil)
    
    self.portfolioNames = []
    self.viewControllerList = []
    
    var viewControllers: [UIViewController] = []
    
    portfolioNames = Defaults[.portfolioNames]
    var allCryptoPortfolioData = Defaults[.cryptoPortfolioData]
    var allFiatPortfolioData = Defaults[.fiatPortfolioData]
    
    if allCryptoPortfolioData.isEmpty && allFiatPortfolioData.isEmpty {
      Defaults[.cryptoPortfolioData] = ["Main": [:]]
      Defaults[.fiatPortfolioData] = ["Main": [:]]
      Defaults[.portfolioNames] = ["Main"]
      allCryptoPortfolioData = Defaults[.cryptoPortfolioData]
      allFiatPortfolioData = Defaults[.fiatPortfolioData]
      portfolioNames = Defaults[.portfolioNames]
    }
    
    for portfolioName in portfolioNames {
      let vc = storyboard.instantiateViewController(withIdentifier: "PortfolioSummaryViewController") as! PortfolioSummaryViewController
      vc.title = portfolioName
      vc.portfolioName = portfolioName
      
      if let data = allCryptoPortfolioData[portfolioName] {
        if let cryptoData = data as? [String: [[String: Any]] ] {
          vc.cryptoPortfolioData = cryptoData
        }
        else {
          vc.cryptoDict = [:]
        }
      }
      if let fiatData =  allFiatPortfolioData[portfolioName]  as? [String: [[String: Any]] ] {
        vc.fiatPortfolioData = fiatData
      }
      else {
        vc.fiatPortfolioData = [:]
      }
      
      viewControllers.append(vc)
    }
    
    return viewControllers
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let destinationVC = segue.destination
    
    if let addPortfolioVC = destinationVC as? AddPortfolioViewController {
      addPortfolioVC.parentController = self
    }
  }
  
  
}

extension MainPortfolioViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return PagingIndexItem(index: index, title: portfolioNames[index]) as! T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return viewControllerList[index]
  }
  
  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return viewControllerList.count
  }
  
}

extension MainPortfolioViewController: PagingViewControllerDelegate {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
    
    if let index = viewControllerList.index(of: destinationViewController) {
      self.currentSelectedIndex = index
    }
  }
  
}

