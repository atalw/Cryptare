//
//  ContainerDashboardViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Parchment

class ContainerDashboardViewController: UIViewController {
    
    let titles = ["All", "Favourites"]
    
    lazy var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        vc1.favouritesTab = false
        let vc2 = storyboard.instantiateViewController(withIdentifier: "FavouriteDashboardViewController") as! DashboardViewController
        vc2.favouritesTab = true
        return [vc1, vc2]
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagingViewController = PagingViewController<PagingIndexItem>()
        pagingViewController.dataSource = self

        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }
    
}

extension ContainerDashboardViewController: PagingViewControllerDataSource {

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
