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
    
    // iap
    @IBOutlet weak var unlockAllDescLabel: UILabel! {
        didSet {
            unlockAllDescLabel.adjustsFontSizeToFitWidth = true
            unlockAllDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var unlockAllPriceLabel: UILabel! {
        didSet {
            unlockAllPriceLabel.text = 0.0.asCurrency
            unlockAllPriceLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var removeAdsDescLabel: UILabel! {
        didSet {
            removeAdsDescLabel.adjustsFontSizeToFitWidth = true
            removeAdsDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var removeAdsPriceLabel: UILabel! {
        didSet {
            removeAdsPriceLabel.text = 0.0.asCurrency
            removeAdsPriceLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var unlockMarketsDescLabel: UILabel! {
        didSet {
            unlockMarketsDescLabel.adjustsFontSizeToFitWidth = true
            unlockMarketsDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var unlockMarketsPriceLabel: UILabel! {
        didSet {
            unlockMarketsPriceLabel.text = 0.0.asCurrency
            unlockMarketsPriceLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var unlockPortfolioDescLabel: UILabel! {
        didSet {
            unlockPortfolioDescLabel.adjustsFontSizeToFitWidth = true
            unlockPortfolioDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var unlockMulitplePortfoliosLabel: UILabel! {
        didSet {
            unlockMulitplePortfoliosLabel.text = 0.0.asCurrency
            unlockMulitplePortfoliosLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    // dashboard
    @IBOutlet weak var favouritesInitialTabDescLabel: UILabel! {
        didSet {
            favouritesInitialTabDescLabel.adjustsFontSizeToFitWidth = true
            favouritesInitialTabDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var favouritesInitialTabSwitch: UISwitch! {
        didSet {
            favouritesInitialTabSwitch.addTarget(self, action: #selector(favouritesInitialTabChange), for: .valueChanged)
        }
    }
    
    // charts
    @IBOutlet weak var lineModeDescLabel: UILabel! {
        didSet {
            lineModeDescLabel.adjustsFontSizeToFitWidth = true
            lineModeDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var linearModeButton: UIButton! {
        didSet {
            linearModeButton.layer.cornerRadius = 5
            linearModeButton.setTitleColor(UIColor.black, for: .normal)
            linearModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            linearModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    @IBOutlet weak var smoothModeButton: UIButton! {
        didSet {
            smoothModeButton.layer.cornerRadius = 5
            smoothModeButton.setTitleColor(UIColor.black, for: .normal)
            smoothModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            smoothModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    @IBOutlet weak var steppedModeButton: UIButton! {
        didSet {
            steppedModeButton.layer.cornerRadius = 5
            steppedModeButton.setTitleColor(UIColor.black, for: .normal)
            steppedModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            steppedModeButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }

    @IBOutlet weak var xAxisDescLabel: UILabel! {
        didSet {
            xAxisDescLabel.adjustsFontSizeToFitWidth = true
            xAxisDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var xAxisSwitch: UISwitch! {
        didSet {
             xAxisSwitch.addTarget(self, action: #selector(xAxisChange), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var xAxisGridLinesDescLabel: UILabel! {
        didSet {
            xAxisGridLinesDescLabel.adjustsFontSizeToFitWidth = true
            xAxisGridLinesDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var xAxisGridLinesSwitch: UISwitch! {
        didSet {
            xAxisGridLinesSwitch.addTarget(self, action: #selector(xAxisGridLinesChange), for: .valueChanged)

        }
    }
    @IBOutlet weak var yAxisDescLabel: UILabel! {
        didSet {
            yAxisDescLabel.adjustsFontSizeToFitWidth = true
            yAxisDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    @IBOutlet weak var yAxisSwitch: UISwitch! {
        didSet {
            yAxisSwitch.addTarget(self, action: #selector(yAxisChange), for: .valueChanged)
        }
    }
    @IBOutlet weak var yAxisGridLinesDescLabel: UILabel! {
        didSet {
            yAxisGridLinesDescLabel.adjustsFontSizeToFitWidth = true
            yAxisGridLinesDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var yAxisGridLinesSwitch: UISwitch! {
        didSet {
            yAxisGridLinesSwitch.addTarget(self, action: #selector(yAxisGridLinesChange), for: .valueChanged)
        }
    }
    
    // markets
    @IBOutlet weak var defaultSortDescLabel: UILabel! {
        didSet {
            defaultSortDescLabel.adjustsFontSizeToFitWidth = true
            defaultSortDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var buySort: UIButton! {
        didSet {
            buySort.layer.cornerRadius = 5
            buySort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            buySort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    @IBOutlet weak var sellSort: UIButton! {
        didSet {
            sellSort.layer.cornerRadius = 5
            sellSort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            sellSort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    
    @IBOutlet weak var defaultOrderDescLabel: UILabel! {
        didSet {
            defaultOrderDescLabel.adjustsFontSizeToFitWidth = true
            defaultOrderDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var ascendingSort: UIButton! {
        didSet {
            ascendingSort.layer.cornerRadius = 5
            ascendingSort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            ascendingSort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    @IBOutlet weak var descendingSort: UIButton! {
        didSet {
            descendingSort.layer.cornerRadius = 5
            descendingSort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            descendingSort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    
    // news
    @IBOutlet weak var defaultNewsSortDesc: UILabel! {
        didSet {
            defaultNewsSortDesc.adjustsFontSizeToFitWidth = true
            defaultNewsSortDesc.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var popularitySort: UIButton! {
        didSet {
            popularitySort.layer.cornerRadius = 5
            popularitySort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            popularitySort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    @IBOutlet weak var dateSort: UIButton! {
        didSet {
            dateSort.layer.cornerRadius = 5
            dateSort.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
            dateSort.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
        }
    }
    
    // currency
    @IBOutlet weak var changeCurrencyDescLabel: UILabel! {
        didSet {
            changeCurrencyDescLabel.adjustsFontSizeToFitWidth = true
            changeCurrencyDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    // tutorials
    @IBOutlet weak var appFeaturesIntroDescLabel: UILabel! {
        didSet {
            appFeaturesIntroDescLabel.adjustsFontSizeToFitWidth = true
            appFeaturesIntroDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    // social
    @IBOutlet weak var twitterDescLabel: UILabel! {
        didSet {
            twitterDescLabel.adjustsFontSizeToFitWidth = true
            twitterDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    @IBOutlet weak var redditDescLabel: UILabel! {
        didSet {
            redditDescLabel.adjustsFontSizeToFitWidth = true
            redditDescLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    // footer
    @IBOutlet weak var appVersionLabel: UILabel! {
        didSet {
            #if PRO_VERSION
                #if DEBUG
                    appVersionLabel?.text = " Cryptare DEBUG v\(Bundle.appVersion)"
                #else
                    appVersionLabel?.text = " Cryptare v\(Bundle.appVersion)"
                #endif
            #endif
            
           appVersionLabel.adjustsFontSizeToFitWidth = true
            appVersionLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    var buttonHighlightedBackgroundColour: UIColor = UIColor.init(hex: "46637F")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
        self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
        
        Armchair.userDidSignificantEvent(true)
        
        loadDashboardSettings()
        loadChartSettings()
        loadMarketSettings()
        loadNewsSettings()
        
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
        
        linearModeButton.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        smoothModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        steppedModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
    }
    
    func smoothSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = true
        steppedModeButton.isSelected = false
        
        linearModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        smoothModeButton.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        steppedModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        
    }
    
    func steppedSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = false
        steppedModeButton.isSelected = true
        
        linearModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        smoothModeButton.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        steppedModeButton.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        
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
            
            buySort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            sellSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        }
        else if Defaults[.marketSort] == "sell" {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            sellSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        }
        
        if Defaults[.marketOrder] == "ascending" {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            descendingSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        }
        else if Defaults[.marketOrder] == "descending" {
            ascendingSort.isSelected = false
            descendingSort.isSelected = true
            
            ascendingSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            descendingSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        }
    }
    
    @IBAction func marketSortButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(buySort) {
            buySort.isSelected = true
            sellSort.isSelected = false
            
            buySort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            sellSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor

            Defaults[.marketSort] = "buy"
        }
        else if (sender as! UIButton).isEqual(sellSort) {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            sellSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            
            Defaults[.marketSort] = "sell"
        }
    }
    
    @IBAction func marketOrderButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(ascendingSort) {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            descendingSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            
            Defaults[.marketOrder] = "ascending"
        }
        else if (sender as! UIButton).isEqual(descendingSort) {
            ascendingSort.isSelected = false
            descendingSort.isSelected = true
            
            ascendingSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            descendingSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            
            Defaults[.marketOrder] = "descending"
        }
    }
    
    func loadNewsSettings() {
        if Defaults[.newsSort] == "popularity" {
            popularitySort.isSelected = true
            dateSort.isSelected = false
            
            popularitySort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            dateSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
        }
        else if Defaults[.newsSort] == "date" {
            popularitySort.isSelected = false
            dateSort.isSelected = true
            
            popularitySort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            dateSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
        }
    }
    @IBAction func newsSortButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(popularitySort) {
            popularitySort.isSelected = true
            dateSort.isSelected = false
            
            popularitySort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            dateSort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            
            Defaults[.newsSort] = "popularity"
        }
        else if (sender as! UIButton).isEqual(dateSort) {
            popularitySort.isSelected = false
            dateSort.isSelected = true
            
            popularitySort.theme_backgroundColor = GlobalPicker.buttonNotSelectedColor
            dateSort.theme_backgroundColor = GlobalPicker.buttonSelectedColor
            
            Defaults[.newsSort] = "date"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        
        header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        cell.textLabel?.theme_textColor = GlobalPicker.viewTextColor
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
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "UnlockMarketsViewController")
                    self.present(controller, animated: true, completion: nil)
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
