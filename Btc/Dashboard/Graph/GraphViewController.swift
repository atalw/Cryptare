//
//  GraphViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Parchment
import Armchair
import SwiftyUserDefaults

class GraphViewController: UIViewController {
    
    let selectedColour = UIColor.init(hex: "#F7B54A")
    
    var parentControler: DashboardViewController!
    
    var databaseTableTitle: String!
    
    let titles = ["Details", "News", "Markets"]
    var favourites: [String] = []
    var favouriteStatus: Bool = false
    var favouriteButton: UIBarButtonItem!
    
    lazy var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let cryptoDetailVC = storyboard.instantiateViewController(withIdentifier: "CryptoDetailViewController") as! CryptoDetailViewController
        cryptoDetailVC.databaseTableTitle = databaseTableTitle
        
        let newsVC = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        for (symbol, name) in GlobalValues.coins {
            if symbol == databaseTableTitle {
                let searchTerm = "\(name) \(symbol) cryptocurrency"
                newsVC.cryptoName = searchTerm
            }
        }
        let marketsVC = storyboard.instantiateViewController(withIdentifier: "MarketViewController") as! MarketViewController
        marketsVC.currentCoin = databaseTableTitle
        
        return [cryptoDetailVC, newsVC, marketsVC]
    }()
    
    let pagingViewController = PagingViewController<PagingIndexItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
        favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
        self.navigationItem.rightBarButtonItem = favouriteButton
        
        for (symbol, name) in GlobalValues.coins {
            if symbol == self.databaseTableTitle {
                self.title = name
            }
        }
        
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 40)
        pagingViewController.menuHorizontalAlignment = .center
        
        print(Defaults[.currentThemeIndex], "currentThemeIndex")
        
        pagingViewController.view.theme_backgroundColor = GlobalPicker.navigationBarTintColor
        pagingViewController.collectionView.theme_backgroundColor = GlobalPicker.navigationBarTintColor
//        pagingViewController.collectionView.backgroundView?.theme_backgroundColor = GlobalPicker.navigationBarTintColor
        
//        pagingViewController.backgroundColor = UIColor.init(hex: "46637F")
//        pagingViewController.selectedBackgroundColor = UIColor.init(hex: "46637F")
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
        getFavouriteList()
        setFavouriteButtonStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func getFavouriteList() {
        favourites = Defaults[.dashboardFavourites]
    }
    
    func setFavouriteButtonStatus() {
        
        if favourites.contains(databaseTableTitle) {
            var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
            image = image?.maskWithColor(color: selectedColour)
            favouriteButton.image = image
            favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
            self.navigationItem.rightBarButtonItem = favouriteButton
            favouriteStatus = true
        }
        else {
            var image = UIImage(named: "favouriteIcon")?.withRenderingMode(.alwaysTemplate)
            image = image?.maskWithColor(color: UIColor.gray)
            favouriteButton.image = image
            favouriteButton = UIBarButtonItem.itemWith(colorfulImage: image, target: self, action: #selector(favouriteButtonTapped))
            self.navigationItem.rightBarButtonItem = favouriteButton
            favouriteStatus = false
        }
        
        Armchair.userDidSignificantEvent(true)
    }
    
    @objc func favouriteButtonTapped() {
        
        if favouriteStatus {
            if !favourites.contains(databaseTableTitle) {
                favouriteStatus = false
            } else {
                for index in 0..<favourites.count {
                    if databaseTableTitle == favourites[index] {
                        favourites.remove(at: index)
                        break
                    }
                }
                favouriteStatus = true
            }
        } else {
            if favourites.contains(databaseTableTitle) {
                favouriteStatus = false
            }
            else {
                favourites.append(databaseTableTitle)
                favouriteStatus = true
            }
        }
        
        Defaults[.dashboardFavourites] = favourites
        
        setFavouriteButtonStatus()
    }
    
    
}

extension GraphViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: titles[index]) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return viewControllerList[index]
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return titles.count
    }
    
}

extension GraphViewController: PagingViewControllerDelegate {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        
//        if let index = viewControllerList.index(of: destinationViewController) {
//            self.currentSelectedIndex = index
//        }
    }
    
}
