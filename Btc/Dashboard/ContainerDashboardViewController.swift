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

//        pagingViewController.menuItemClass =
//        pagingViewController.menuItemSize = .fixed(width: 60, height: 60)
//        pagingViewController.textColor = UIColor(red: 0.51, green: 0.54, blue: 0.56, alpha: 1)
//        pagingViewController.selectedTextColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
//        pagingViewController.indicatorColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
//        pagingViewController.select(pagingItem: IconItem(icon: icons[0], index: 0))

        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)

        
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


//class ContainerDashboardViewController: UIPageViewController, UIPageViewControllerDataSource {
//
//    lazy var viewControllerList: [UIViewController] = {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let vc1 = storyboard.instantiateViewController(withIdentifier: "DashboardViewController")
//        let vc2 = storyboard.instantiateViewController(withIdentifier: "FavouriteDashboardViewController")
//
//        return [vc1, vc2]
//    }()
//
//    @IBOutlet weak var currencyButton: UIBarButtonItem!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.dataSource = self
//
//        if let firstViewController = viewControllerList.first {
//            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
//        }
//
//        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
//
//        let currency = GlobalValues.currency!
//        currencyButton.title = currency
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//
//        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
//
//        let previousIndex = vcIndex - 1
//
//        guard previousIndex >= 0 else { return nil }
//
//        guard viewControllerList.count > previousIndex else { return nil }
//
//        return viewControllerList[previousIndex]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
//
//        let nextIndex = vcIndex + 1
//
//        guard viewControllerList.count != nextIndex else { return nil }
//
//        guard viewControllerList.count > nextIndex else { return nil }
//
//        if nextIndex == 1 {
//            (viewControllerList[nextIndex] as? DashboardViewController)?.favouritesTab = true
//        }
//
//        return viewControllerList[nextIndex]
//    }
//
//
//    /*
//     // MARK: - Navigation
//
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//
//}


