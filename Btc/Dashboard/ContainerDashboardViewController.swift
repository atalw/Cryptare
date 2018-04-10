//
//  ContainerDashboardViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Parchment
import SwiftyUserDefaults

class ContainerDashboardViewController: UIViewController {
    
    var currency: String!
    
    lazy var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        vc1.favouritesTab = false
        vc1.title = "All"
        
        let vc2 = storyboard.instantiateViewController(withIdentifier: "FavouriteDashboardViewController") as! DashboardViewController
        vc2.favouritesTab = true
        vc2.title = "Favourites"
        
        let favouriteFirstDefaults = Defaults[.dashboardFavouritesFirstTab]

        return favouriteFirstDefaults ? [vc2, vc1] : [vc1, vc2]
    }()
    
    let pagingViewController = PagingViewController<PagingIndexItem>()
    var currentSelectedIndex: Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor

        if GlobalValues.currency != nil {
            currency = GlobalValues.currency!
        }
       
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        pagingViewController.collectionView.theme_backgroundColor = GlobalPicker.navigationBarTintColor
        
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
        
        for (index, viewController) in viewControllerList.enumerated() {
            if let dashboardVC = viewController as? DashboardViewController {
                if dashboardVC.tableView != nil {
                    if let selectedTableIndex = dashboardVC.tableView.indexPathForSelectedRow {
                        dashboardVC.tableView.deselectRow(at: selectedTableIndex, animated: true)
                    }
                }
                
                if currency != GlobalValues.currency! {
                    currency = GlobalValues.currency!
                    
                    dashboardVC.currency = currency
                    
                    guard let currentIndex = currentSelectedIndex else { return }
                    
                    if index == currentIndex {
                        dashboardVC.loadAllCoinData()
                    }
                }
            }
        }
    }
    
}

extension ContainerDashboardViewController: PagingViewControllerDataSource {

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

extension ContainerDashboardViewController: PagingViewControllerDelegate {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        
        if let index = viewControllerList.index(of: destinationViewController) {
            self.currentSelectedIndex = index
        }
    }
    
}
