//
//  MainViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import GoogleMobileAds
import SwiftyUserDefaults

class MainViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var dashboardVC: DashboardViewController!
    var favouritesVC: DashboardViewController!
    
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        if #available(iOS 11.0, *) {
           navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = "Search"
        
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.barStyle = .default
        searchController.searchResultsUpdater =  self

        let scb = searchController.searchBar
        
        scb.tintColor = UIColor.white
        scb.barTintColor = UIColor.white
        
        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.blue
            if let backgroundview = textfield.subviews.first {
                
                // Background color
                backgroundview.backgroundColor = UIColor.white
                
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let removeAdsPurchased: Bool = Defaults[.removeAdsPurchased]
        #if DEBUG
            bannerView.isHidden = true
        #else
            if removeAdsPurchased == false {
                bannerView.load(GADRequest())
                bannerView.delegate = self
            }
            else {
                bannerView.isHidden = true
            }
        #endif
        
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

extension MainViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
