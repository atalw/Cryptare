//
//  MainViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class MainViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var dashboardVC: DashboardViewController!
    var favouritesVC: DashboardViewController!
    
    @IBOutlet weak var currencyButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
           navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = "Search"
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.searchResultsUpdater =  self


        // Do any additional setup after loading the view.
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
        
        let currency = GlobalValues.currency!
        currencyButton.title = currency
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let containerDashboardVC = destinationVC as? ContainerDashboardViewController {
            if let dashboardVC = containerDashboardVC.viewControllerList[0] as? DashboardViewController,
                let favouritesVC = containerDashboardVC.viewControllerList[1] as? DashboardViewController {
                
                dashboardVC.parentController = self
                self.dashboardVC = dashboardVC
                
                favouritesVC.parentController = self
                self.favouritesVC = favouritesVC
//                searchController.searchResultsUpdater = favouritesVC
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        dashboardVC.coinSearchResults = dashboardVC.coins.filter( {( coin: String ) -> Bool in
            var coinName: String = coin
            for (symbol, name) in GlobalValues.coins {
                if symbol == coin {
                    coinName = name
                }
            }
            if coin.lowercased().contains(searchText.lowercased()) ||
                coinName.lowercased().contains(searchText.lowercased()) {
                return true
            }
            else { return false }
        })
        
        favouritesVC.coinSearchResults = favouritesVC.coins.filter( {( coin: String ) -> Bool in
            var coinName: String = coin
            for (symbol, name) in GlobalValues.coins {
                if symbol == coin {
                    coinName = name
                }
            }
            if coin.lowercased().contains(searchText.lowercased()) ||
                coinName.lowercased().contains(searchText.lowercased()) {
                return true
            }
            else { return false }
        })
        
        dashboardVC.tableView.reloadData()
        favouritesVC.tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MainViewController: SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        //        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        //        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        //        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        //        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        //        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        //        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        //        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        //        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
