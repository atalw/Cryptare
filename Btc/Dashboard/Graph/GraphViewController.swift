//
//  GraphViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Parchment

class GraphViewController: UIViewController {
    
    var parentControler: DashboardViewController!
    
    var databaseTableTitle: String!
    
    let titles = ["Details", "News", "Markets"]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (symbol, name) in GlobalValues.coins {
            if symbol == self.databaseTableTitle {
                self.title = name
            }
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let pagingViewController = PagingViewController<PagingIndexItem>()
        pagingViewController.dataSource = self
        
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 40)
        pagingViewController.menuHorizontalAlignment = .center
        
        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
