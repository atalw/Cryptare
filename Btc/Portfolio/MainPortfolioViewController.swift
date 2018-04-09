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

class MainPortfolioViewController: UIViewController {
    
    // dev-------------------------------
    let portfolioEntries: [[Int:Any]] = [
        [4: 798436.4399999999, 2: 1, 0: "BTC", 3: "2018-01-28", 1: "buy"],
        [4: 371513.745, 2: 0.5, 0: "BTC", 3: "2018-02-28", 1: "sell"],
        [4: 1178481.7, 2: 58, 0: "LTC", 3: "2017-12-28", 1: "buy"],
        [4: 182723.24, 2: 14, 0: "LTC", 3: "2018-01-28", 1: "sell"]
    ]
    // ------------------------------------
    
    var currency: String!

    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let pagingViewController = PagingViewController<PagingIndexItem>()

    lazy var viewControllerList: [UIViewController] = {
        return getPortfolios()
    }()
    
    var portfolioNames: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagingViewController.view.theme_backgroundColor = GlobalPicker.navigationBarTintColor
        pagingViewController.collectionView.theme_backgroundColor = GlobalPicker.navigationBarTintColor
        
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        
//        let newData = NSKeyedArchiver.archivedData(withRootObject: portfolioEntries)
//        UserDefaults.standard.set(newData, forKey: "portfolioEntries")
//        
//        UserDefaults.standard.remove("fiatPortfolioEntries")
        
        currency = GlobalValues.currency!
        
        dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.timeZone = TimeZone.current
        
        updateOldFormatPortfolioEntries()
        
        self.title = "Portfolio"
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

        pagingViewController.dataSource = self
        
//        pagingViewController.backgroundColor = UIColor.init(hex: "46637F")
//        pagingViewController.selectedBackgroundColor = UIColor.init(hex: "46637F")
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
                    
                    if let coin = firstElement, let type = secondElement, let amountOfCoins = thirdElement, let dateString = fourthElement, let costPerCoin = fifthElement {
                        
                        let tradingPair = GlobalValues.currency!
                        let exchange = "None"
                        let fees = 0
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
                        let date = dateFormatter.date(from: "\(dateString) 12:00 AM")
                        
                        if data["Main"]![coin] == nil {
                            data["Main"]![coin] = []
                        }
                        
                        let transaction: [String : Any] = ["type": type,
                                                           "tradingPair": tradingPair,
                                                           "exchange": exchange,
                                                           "costPerCoin": costPerCoin,
                                                           "amountOfCoins": amountOfCoins,
                                                           "fees": fees,
                                                           "date": date!]
                        data["Main"]![coin]!.append(transaction)
                    }
                }
            }
            Defaults[.cryptoPortfolioData] = data
            Defaults[.portfolioNames] = ["Main"]
        }
    }
    
    

    @IBAction func addPortfolioButtonTapped(_ sender: Any) {
        if let addPortfolioViewController = self.storyboard?.instantiateViewController(withIdentifier: "addPortfolioViewController") as? AddPortfolioViewController {
            addPortfolioViewController.parentController = self
//            addPortfolioViewController.portfolioNames = self.portfolioNames
            self.navigationController?.pushViewController(addPortfolioViewController, animated: true)
        }
    }
    
    func getPortfolios() -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
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
            if let data = allCryptoPortfolioData[portfolioName] {
                let vc = storyboard.instantiateViewController(withIdentifier: "PortfolioSummaryViewController") as! PortfolioSummaryViewController
                vc.title = portfolioName
                vc.portfolioName = portfolioName
                
                if let cryptoData = data as? [String: [[String: Any]] ] {
                    vc.cryptoPortfolioData = cryptoData
                }
                else {
                    vc.cryptoDict = [:]
                }
                
                if let fiatData =  allFiatPortfolioData[portfolioName]  as? [String: [[String: Any]] ] {
                    vc.fiatPortfolioData = fiatData
                }
                else {
                    vc.fiatPortfolioData = [:]
                }
                
                viewControllers.append(vc)

            }
        }
        
//        for (name, data) in allCryptoPortfolioData {
//            let vc = storyboard.instantiateViewController(withIdentifier: "PortfolioSummaryViewController") as! PortfolioSummaryViewController
//            self.portfolioNames.append(name)
//            vc.title = name
//            vc.portfolioName = name
//
//            if let cryptoPortfolioData = data as? [String: [[String: Any]] ] {
//                vc.cryptoPortfolioData = cryptoPortfolioData
//
//                if let fiatData =  allFiatPortfolioData[name]  as? [String: [[String: Any]] ] {
//                    vc.fiatPortfolioData = fiatData
//                }
//                else {
//                    vc.fiatPortfolioData = [:]
//                }
//
//                viewControllers.append(vc)
//            }
//            else {
//                vc.cryptoPortfolioData = [:]
//            }
//        }
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

