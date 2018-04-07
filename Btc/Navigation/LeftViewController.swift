//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SwiftyUserDefaults

enum LeftMenu: Int {
    case dashboard = 0
    case portfolio
    case news
    case settings
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nightModeDescLabel: UILabel! {
        didSet {
            nightModeDescLabel.adjustsFontSizeToFitWidth = true
            nightModeDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var nightModeSwitch: UISwitch! {
        didSet {
            nightModeSwitch.addTarget(self, action: #selector(nightModeSwitchTapped), for: .touchUpInside)
        }
    }
    
    var menus = ["Dashboard", "Portfolio", "News", "Settings"]
    var mainViewController: UIViewController!
    var mainPortfolioViewController: UIViewController!
    var newsViewController: UIViewController!
    var settingsViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
        self.tableView.theme_backgroundColor = GlobalPicker.mainBackgroundColor
        
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        #endif
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.mainViewController = UINavigationController(rootViewController: mainViewController)
        
        let mainPortfolioViewController = storyboard.instantiateViewController(withIdentifier: "MainPortfolioViewController") as! MainPortfolioViewController
        self.mainPortfolioViewController = UINavigationController(rootViewController: mainPortfolioViewController)
        
        let newsViewController = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        self.newsViewController = UINavigationController(rootViewController: newsViewController)
        
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.settingsViewController = UINavigationController(rootViewController: settingsViewController)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentThemeIndex = Defaults[.currentThemeIndex]
        if currentThemeIndex == 1 {
            nightModeSwitch.setOn(true, animated: true)
        }
        else {
            nightModeSwitch.setOn(false, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    @objc func nightModeSwitchTapped() {
        if nightModeSwitch.isOn {
            ColourThemes.switchTheme(theme: .night)
        }
        else {
            ColourThemes.switchTheme(theme: .light)
        }
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .dashboard:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .portfolio:
            self.slideMenuController()?.changeMainViewController(self.mainPortfolioViewController, close: true)
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
            case .dashboard, .portfolio, .news, .settings:
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
            case .dashboard, .portfolio, .news, .settings:
                let cell = tableView.dequeueReusableCell(withIdentifier: "navigationCell", for: indexPath) as! LeftNavigationTableViewCell
                cell.setData(menus[indexPath.row])
                cell.theme_backgroundColor = GlobalPicker.mainBackgroundColor
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // set dashboard as default selected row
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            (tableView.cellForRow(at: indexPath) as? LeftNavigationTableViewCell)?.titleLabel.textColor = UIColor.white
        }
    }
}
