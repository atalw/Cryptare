//
//  SettingsViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 08/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Charts
import Armchair
import SwiftyUserDefaults

class SettingsViewController: UITableViewController {
    
    // dashboard
    @IBOutlet weak var favouritesInitialTabSwitch: UISwitch!
    
    // charts
    @IBOutlet weak var linearModeButton: UIButton!
    @IBOutlet weak var smoothModeButton: UIButton!
    @IBOutlet weak var steppedModeButton: UIButton!

    @IBOutlet weak var xAxisSwitch: UISwitch!
    @IBOutlet weak var xAxisGridLinesSwitch: UISwitch!

    @IBOutlet weak var yAxisSwitch: UISwitch!
    @IBOutlet weak var yAxisGridLinesSwitch: UISwitch!
    
    // markets
    @IBOutlet weak var buySort: UIButton!
    @IBOutlet weak var sellSort: UIButton!
    @IBOutlet weak var ascendingSort: UIButton!
    @IBOutlet weak var descendingSort: UIButton!
    
    // news
    @IBOutlet weak var popularitySort: UIButton!
    @IBOutlet weak var dateSort: UIButton!
    
    @IBOutlet weak var unlockAllPriceLabel: UILabel!
    @IBOutlet weak var removeAdsPriceLabel: UILabel!
    @IBOutlet weak var unlockMarketsPriceLabel: UILabel!
    @IBOutlet weak var unlockMulitplePortfoliosLabel: UILabel!
    
    // footer
    @IBOutlet weak var appVersionLabel: UILabel!
    
    var buttonHighlightedBackgroundColour: UIColor = UIColor.init(hex: "46637F")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Armchair.userDidSignificantEvent(true)
        
        self.unlockAllPriceLabel.text = 0.0.asCurrency
        self.removeAdsPriceLabel.text = 0.0.asCurrency
        self.unlockMulitplePortfoliosLabel.text = 0.0.asCurrency
        
        // dashboard
        favouritesInitialTabSwitch.addTarget(self, action: #selector(favouritesInitialTabChange), for: .valueChanged)
        
        //chart
        linearModeButton.layer.cornerRadius = 5
        smoothModeButton.layer.cornerRadius = 5
        steppedModeButton.layer.cornerRadius = 5
        
        linearModeButton.setTitleColor(UIColor.black, for: .normal)
        smoothModeButton.setTitleColor(UIColor.black, for: .normal)
        steppedModeButton.setTitleColor(UIColor.black, for: .normal)
        
        linearModeButton.setTitleColor(UIColor.white, for: .selected)
        smoothModeButton.setTitleColor(UIColor.white, for: .selected)
        steppedModeButton.setTitleColor(UIColor.white, for: .selected)
        
        xAxisSwitch.addTarget(self, action: #selector(xAxisChange), for: .valueChanged)
        xAxisGridLinesSwitch.addTarget(self, action: #selector(xAxisGridLinesChange), for: .valueChanged)

        yAxisSwitch.addTarget(self, action: #selector(yAxisChange), for: .valueChanged)
        yAxisGridLinesSwitch.addTarget(self, action: #selector(yAxisGridLinesChange), for: .valueChanged)
        
        // markets
        buySort.layer.cornerRadius = 5
        sellSort.layer.cornerRadius = 5
        
        buySort.setTitleColor(UIColor.black, for: .normal)
        sellSort.setTitleColor(UIColor.black, for: .normal)
        
        sellSort.setTitleColor(UIColor.white, for: .selected)
        buySort.setTitleColor(UIColor.white, for: .selected)
        
        ascendingSort.layer.cornerRadius = 5
        descendingSort.layer.cornerRadius = 5
        
        ascendingSort.setTitleColor(UIColor.black, for: .normal)
        descendingSort.setTitleColor(UIColor.black, for: .normal)
        
        ascendingSort.setTitleColor(UIColor.white, for: .selected)
        descendingSort.setTitleColor(UIColor.white, for: .selected)
        
        // news
        popularitySort.layer.cornerRadius = 5
        dateSort.layer.cornerRadius = 5
        
        popularitySort.setTitleColor(UIColor.black, for: .normal)
        dateSort.setTitleColor(UIColor.black, for: .normal)
        
        popularitySort.setTitleColor(UIColor.white, for: .selected)
        dateSort.setTitleColor(UIColor.white, for: .selected)
        
        // social
//        twitterCell.se
        
        loadDashboardSettings()
        loadChartSettings()
        loadMarketSettings()
        loadNewsSettings()
        
        #if PRO_VERSION
            #if DEBUG
                appVersionLabel?.text = " Cryptare DEBUG v\(Bundle.appVersion)"
            #else
                appVersionLabel?.text = " Cryptare v\(Bundle.appVersion)"
            #endif
        #endif
        
        #if LITE_VERSION
            appVersionLabel?.text = " CryptareLite v\(Bundle.appVersion)"
        #endif
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let unlockAll: Bool = Defaults[.unlockAllPurchased]
        let removeAdsPurchased: Bool = Defaults[.removeAdsPurchased]
        let unlockMarketsPurchased: Bool = Defaults[.unlockMarketsPurchased]
        let unlockMultiplePortfoliosPurchased: Bool = Defaults[.multiplePortfoliosPurchased]
        let paidUser: Bool = Defaults[.previousPaidUser]
        
        IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
            if success {
                if products != nil {
                    if !paidUser {
                        if products!.count > 1 {
                            if unlockAll {
                                self.unlockAllPriceLabel.text = "Already purchased"
                            }
                            else {
                                for product in products! {
                                    if product.localizedTitle == "Unlock All" {
                                        self.unlockAllPriceLabel.text = product.localizedPrice()

                                    }
                                }
                            }
                            
                            if removeAdsPurchased {
                                self.removeAdsPriceLabel.text = "Already purchased"
                            }
                            else {
                                for product in products! {
                                    if product.localizedTitle == "Remove Ads" {
                                        self.removeAdsPriceLabel.text = product.localizedPrice()
                                        
                                    }
                                }
                            }
                            
                            if unlockMarketsPurchased {
                                self.unlockMarketsPriceLabel.text = "Already purchased"
                            }
                            else {
                                for product in products! {
                                    if product.localizedTitle == "Unlock all markets" {
                                        self.unlockMarketsPriceLabel.text = "Learn more - \(product.localizedPrice())"
                                        
                                    }
                                }
                            }
                            
                            if unlockMultiplePortfoliosPurchased {
                                self.unlockMulitplePortfoliosLabel.text = "Already purchased"
                            }
                            else {
                                for product in products! {
                                    if product.localizedTitle == "Multiple Portfolios" {
                                        self.unlockMulitplePortfoliosLabel.text = product.localizedPrice()
                                        
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self.unlockAllPriceLabel.text = "Already purchased"
                        self.removeAdsPriceLabel.text = "Already purchased"
                        self.unlockMarketsPriceLabel.text = "Already purchased"
                        self.unlockMulitplePortfoliosLabel.text = "Already purchased"
                    }
                }
            }
        })
    }
    
    @objc func favouritesInitialTabChange(favouritesInitialTabSwitch: UISwitch) {
        let state = favouritesInitialTabSwitch.isOn
        Defaults[.dashboardFavouritesFirstTab] = state
    }
    
    @objc func xAxisChange(xAxisSwitch: UISwitch) {
        let state = xAxisSwitch.isOn
        ChartSettings.xAxis = state
        xAxisGridLinesSwitch.isEnabled = state
        Defaults[.xAxis] = state
    }
    
    @objc func xAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = xAxisGridLinesSwitch.isOn
        
        ChartSettings.xAxisGridLinesEnabled = state
        Defaults[.xAxisGridLinesEnabled] = state
    }
    
    @objc func yAxisChange(xAxisSwitch: UISwitch) {
        let state = yAxisSwitch.isOn
        
        ChartSettings.yAxis = state
        yAxisGridLinesSwitch.isEnabled = state
        Defaults[.yAxis] = state
    }
    
    @objc func yAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = yAxisGridLinesSwitch.isOn
        
        ChartSettings.yAxisGridLinesEnabled = state
        Defaults[.yAxisGridLinesEnabled] = state
    }

    @IBAction func linearButtonTapped(_ sender: Any) {
        linearSelected()
        ChartSettings.chartMode = "linear"
        Defaults[.chartMode] = "linear"
    }
    
    @IBAction func smoothButtonTapped(_ sender: Any) {
        smoothSelected()
        ChartSettings.chartMode = "smooth"
        Defaults[.chartMode] = "smooth"
    }
    
    @IBAction func steppedButtonTapped(_ sender: Any) {
        steppedSelected()
        ChartSettings.chartMode = "stepped"
        Defaults[.chartMode] = "stepped"
    }
    
    func linearSelected() {
        linearModeButton.isSelected = true
        smoothModeButton.isSelected = false
        steppedModeButton.isSelected = false
        
        linearModeButton.backgroundColor = buttonHighlightedBackgroundColour
        smoothModeButton.backgroundColor = UIColor.white
        steppedModeButton.backgroundColor = UIColor.white
        
    }
    
    func smoothSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = true
        steppedModeButton.isSelected = false
        
        linearModeButton.backgroundColor = UIColor.white
        smoothModeButton.backgroundColor = buttonHighlightedBackgroundColour
        steppedModeButton.backgroundColor = UIColor.white
        
    }
    
    func steppedSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = false
        steppedModeButton.isSelected = true
        
        linearModeButton.backgroundColor = UIColor.white
        smoothModeButton.backgroundColor = UIColor.white
        steppedModeButton.backgroundColor = buttonHighlightedBackgroundColour
        
    }

    @IBAction func chartResetDefaults(_ sender: Any) {
        ChartSettings.chartMode = ChartSettingsDefault.chartMode
        
        ChartSettings.xAxis = ChartSettingsDefault.xAxis
        ChartSettings.xAxisGridLinesEnabled = ChartSettingsDefault.xAxisGridLinesEnabled
        
        ChartSettings.yAxis = ChartSettingsDefault.yAxis
        ChartSettings.yAxisGridLinesEnabled = ChartSettingsDefault.yAxisGridLinesEnabled
        
        Defaults[.chartMode] = ChartSettingsDefault.chartMode
        
        Defaults[.xAxis] = ChartSettingsDefault.xAxis
        Defaults[.xAxisGridLinesEnabled] = ChartSettingsDefault.xAxisGridLinesEnabled
        
        Defaults[.yAxis] = ChartSettingsDefault.yAxis
        Defaults[.yAxisGridLinesEnabled] = ChartSettingsDefault.yAxisGridLinesEnabled
        
        loadChartSettings()
    }
    
    func loadDashboardSettings() {
        favouritesInitialTabSwitch.isOn = Defaults[.dashboardFavouritesFirstTab]
    }
    
    func loadChartSettings() {
        // chart mode
        if ChartSettings.chartMode == "linear" {
            linearSelected()
        }
        else if ChartSettings.chartMode == "smooth" {
            smoothSelected()
        }
        else if ChartSettings.chartMode == "stepped" {
            steppedSelected()
        }
        
        // x-axis
        xAxisSwitch.setOn(ChartSettings.xAxis, animated: true)
        xAxisGridLinesSwitch.setOn(ChartSettings.xAxisGridLinesEnabled, animated: true)
        
        if !xAxisSwitch.isOn {
            xAxisGridLinesSwitch.isEnabled = false
        }
        
        // y-axis
        yAxisSwitch.setOn(ChartSettings.yAxis, animated: true)
        yAxisGridLinesSwitch.setOn(ChartSettings.yAxisGridLinesEnabled, animated: true)
        
        if !yAxisSwitch.isOn {
            yAxisGridLinesSwitch.isEnabled = false
        }
    }
    
    func loadMarketSettings() {
        if Defaults[.marketSort] == "buy" {
            buySort.isSelected = true
            sellSort.isSelected = false
            
            buySort.backgroundColor = buttonHighlightedBackgroundColour
            sellSort.backgroundColor = UIColor.white
        }
        else if Defaults[.marketSort] == "sell" {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.backgroundColor = UIColor.white
            sellSort.backgroundColor = buttonHighlightedBackgroundColour
        }
        
        if Defaults[.marketOrder] == "ascending" {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.backgroundColor = buttonHighlightedBackgroundColour
            descendingSort.backgroundColor = UIColor.white
        }
        else if Defaults[.marketOrder] == "descending" {
            ascendingSort.isSelected = false
            descendingSort.isSelected = true
            
            ascendingSort.backgroundColor = UIColor.white
            descendingSort.backgroundColor = buttonHighlightedBackgroundColour
        }
    }
    
    @IBAction func marketSortButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(buySort) {
            buySort.isSelected = true
            sellSort.isSelected = false
            
            buySort.backgroundColor = buttonHighlightedBackgroundColour
            sellSort.backgroundColor = UIColor.white
            
            Defaults[.marketSort] = "buy"
        }
        else if (sender as! UIButton).isEqual(sellSort) {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.backgroundColor = UIColor.white
            sellSort.backgroundColor = buttonHighlightedBackgroundColour
            
            Defaults[.marketSort] = "sell"
        }
    }
    
    @IBAction func marketOrderButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(ascendingSort) {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.backgroundColor = buttonHighlightedBackgroundColour
            descendingSort.backgroundColor = UIColor.white
            
            Defaults[.marketOrder] = "ascending"
        }
        else if (sender as! UIButton).isEqual(descendingSort) {
            ascendingSort.isSelected = false
            descendingSort.isSelected = true
            
            ascendingSort.backgroundColor = UIColor.white
            descendingSort.backgroundColor = buttonHighlightedBackgroundColour
            
            Defaults[.marketOrder] = "descending"
        }
    }
    
    func loadNewsSettings() {
        if Defaults[.newsSort] == "popularity" {
            popularitySort.isSelected = true
            dateSort.isSelected = false
            
            popularitySort.backgroundColor = buttonHighlightedBackgroundColour
            dateSort.backgroundColor = UIColor.white
        }
        else if Defaults[.newsSort] == "date" {
            popularitySort.isSelected = false
            dateSort.isSelected = true
            
            popularitySort.backgroundColor = UIColor.white
            dateSort.backgroundColor = buttonHighlightedBackgroundColour
        }
    }
    @IBAction func newsSortButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(popularitySort) {
            popularitySort.isSelected = true
            dateSort.isSelected = false
            
            popularitySort.backgroundColor = buttonHighlightedBackgroundColour
            dateSort.backgroundColor = UIColor.white
            
            Defaults[.newsSort] = "popularity"
        }
        else if (sender as! UIButton).isEqual(dateSort) {
            popularitySort.isSelected = false
            dateSort.isSelected = true
            
            popularitySort.backgroundColor = UIColor.white
            dateSort.backgroundColor = buttonHighlightedBackgroundColour
            
            Defaults[.newsSort] = "date"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unlockAllPurchased: Bool = Defaults[.unlockAllPurchased]
        let removeAdsPurchased: Bool = Defaults[.removeAdsPurchased]
        let unlockMarketsPurchased: Bool = Defaults[.unlockMarketsPurchased]
        let unlockMultiplePortfoliosPurchased: Bool = Defaults[.multiplePortfoliosPurchased]

        if indexPath.section == 0 { // in-app purchases
            
            if !unlockAllPurchased {
                if indexPath.row == 0 {
                    IAPService.shared.purchase(product: .unlockAll, completionHandlerBool: { (success) -> Void in
                        
                    })
                }
            }
            
            if !removeAdsPurchased {
                if indexPath.row == 1 {
                    IAPService.shared.purchase(product: .removeAds, completionHandlerBool: { (success) -> Void in
                        
                    })
                }
            }
            
            if !unlockMarketsPurchased {
                if indexPath.row == 2 {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "UnlockMarketsViewController")
                    self.present(controller, animated: true, completion: nil)
                }
            }
            
            if !unlockMultiplePortfoliosPurchased {
                if indexPath.row == 3 {
                    IAPService.shared.purchase(product: .multiplePortfolios, completionHandlerBool: { (success) -> Void in
                        
                    })
                }
            }
            
            if indexPath.row == 4 {
                IAPService.shared.restorePurchases()
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 1 { // Remove all favourites
                Defaults[.dashboardFavourites] = []
            }
        }
        else if indexPath.section == 7 { // social
            if indexPath.row == 0 { //twitter
                let url = URL(string: "https://twitter.com/cryptare")
                UIApplication.shared.openURL(url!)
            }
            else if indexPath.row == 1 {
                let url = URL(string: "http://reddit.com/r/bitcoin")
                UIApplication.shared.openURL(url!)
            }
        }
        
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
