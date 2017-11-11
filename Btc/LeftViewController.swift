//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case dashboard = 0
//    case portfolio
    case markets
    case news
    case settings
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
//    var menus = ["Dashboard", "Portfolio", "Markets", "News", "Settings"]
    var menus = ["Dashboard", "Markets", "News", "Settings"]
    var dashboardViewController: UIViewController!
    var portfolioViewController: UIViewController!
    var marketViewController: UIViewController!
    var newsViewController: UIViewController!
    var settingsViewController: UIViewController!
    
//    var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        #endif
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        
        let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.dashboardViewController = UINavigationController(rootViewController: dashboardViewController)
        
//        let portfolioViewController = storyboard.instantiateViewController(withIdentifier: "PortfolioTableViewController") as! PortfolioTableViewController
//        self.portfolioViewController = UINavigationController(rootViewController: portfolioViewController)
        
        let marketViewController = storyboard.instantiateViewController(withIdentifier: "MarketViewController") as! MarketViewController
        self.marketViewController = UINavigationController(rootViewController: marketViewController)
        
        let newsViewController = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        self.newsViewController = UINavigationController(rootViewController: newsViewController)
        
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.settingsViewController = UINavigationController(rootViewController: settingsViewController)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .dashboard:
            self.slideMenuController()?.changeMainViewController(self.dashboardViewController, close: true)
//        case .portfolio:
//            self.slideMenuController()?.changeMainViewController(self.portfolioViewController, close: true)
        case .markets:
            self.slideMenuController()?.changeMainViewController(self.marketViewController, close: true)
        case .news:
            self.slideMenuController()?.changeMainViewController(self.newsViewController, close: true)
        case .settings:
            self.slideMenuController()?.changeMainViewController(self.settingsViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
//            case .dashboard, .portfolio, .markets, .news, .settings:
            case .dashboard, .markets, .news, .settings:
                return 50
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
//            case .dashboard, .portfolio, .markets, .news, .settings:
            case .dashboard, .markets, .news, .settings:
                let cell = tableView.dequeueReusableCell(withIdentifier: "navigationCell", for: indexPath) as! LeftNavigationTableViewCell
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // set dashboard as default selected row
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}
