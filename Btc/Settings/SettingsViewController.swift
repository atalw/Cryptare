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

class SettingsViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
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
    
    @IBOutlet weak var removeAdsPriceLabel: UILabel!
    @IBOutlet weak var unlockMarketsPriceLabel: UILabel!
    
    // footer
    @IBOutlet weak var appVersionLabel: UILabel!
    
    var buttonHighlightedBackgroundColour: UIColor = UIColor.init(hex: "46637F")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Armchair.userDidSignificantEvent(true)
        
        self.removeAdsPriceLabel.text = 0.0.asCurrency
        
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
        
        let removeAdsPurchased: Bool = UserDefaults.standard.bool(forKey: "removeAdsPurchased")
        let unlockMarketsPurchased: Bool = UserDefaults.standard.bool(forKey: "unlockMarketsPurchased")
        let paidUser: Bool = UserDefaults.standard.bool(forKey: "paidUser")
        
        IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
            if success {
                if products != nil {
                    if !paidUser {
                        if products!.count > 1 {
                            if removeAdsPurchased {
                                self.removeAdsPriceLabel.text = "Already purchased"
                            }
                            else {
                                self.removeAdsPriceLabel.text = products![0].localizedPrice()
                            }
                            
                            if unlockMarketsPurchased {
                                self.unlockMarketsPriceLabel.text = "Already purchased"
                            }
                        }
                    }
                    else {
                        self.removeAdsPriceLabel.text = "Already purchased"
                        self.unlockMarketsPriceLabel.text = "Already purchased"
                    }
                }
            }
        })
    }
    
    @objc func favouritesInitialTabChange(favouritesInitialTabSwitch: UISwitch) {
        let state = favouritesInitialTabSwitch.isOn
        defaults.set(state, forKey: "favouritesFirstTab")
    }
    
    @objc func xAxisChange(xAxisSwitch: UISwitch) {
        let state = xAxisSwitch.isOn
        if state {
            ChartSettings.xAxis = true
            xAxisGridLinesSwitch.isEnabled = true
            defaults.set(true, forKey: "xAxis")
        }
        else {
            ChartSettings.xAxis = false
            xAxisGridLinesSwitch.isEnabled = false
            defaults.set(false, forKey: "xAxis")
        }
    }
    
    @objc func xAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = xAxisGridLinesSwitch.isOn
        if state {
            ChartSettings.xAxisGridLinesEnabled = true
            defaults.set(true, forKey: "xAxisGridLinesEnabled")
        }
        else {
            ChartSettings.xAxisGridLinesEnabled = false
            defaults.set(false, forKey: "xAxisGridLinesEnabled")
        }
    }
    
    @objc func yAxisChange(xAxisSwitch: UISwitch) {
        let state = yAxisSwitch.isOn
        if state {
            ChartSettings.yAxis = true
            yAxisGridLinesSwitch.isEnabled = true
            defaults.set(true, forKey: "yAxis")
        }
        else {
            ChartSettings.yAxis = false
            yAxisGridLinesSwitch.isEnabled = false
            defaults.set(false, forKey: "yAxis")
        }
    }
    
    @objc func yAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = yAxisGridLinesSwitch.isOn
        if state {
            ChartSettings.yAxisGridLinesEnabled = true
            defaults.set(true, forKey: "yAxisGridLinesEnabled")
        }
        else {
            ChartSettings.yAxisGridLinesEnabled = false
            defaults.set(false, forKey: "yAxisGridLinesEnabled")
        }
    }

    @IBAction func linearButtonTapped(_ sender: Any) {
        linearSelected()
        ChartSettings.chartMode = "linear"
        defaults.set("linear", forKey: "chartMode")
    }
    
    @IBAction func smoothButtonTapped(_ sender: Any) {
        smoothSelected()
        ChartSettings.chartMode = "smooth"
        defaults.set("smooth", forKey: "chartMode")
    }
    
    @IBAction func steppedButtonTapped(_ sender: Any) {
        steppedSelected()
        ChartSettings.chartMode = "stepped"
        defaults.set("stepped", forKey: "chartMode")
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
        
        defaults.set(ChartSettingsDefault.chartMode, forKey: "chartMode")
        
        defaults.set(ChartSettingsDefault.xAxis, forKey: "xAxis")
        defaults.set(ChartSettingsDefault.xAxisGridLinesEnabled, forKey: "xAxisGridLinesEnabled")
        
        defaults.set(ChartSettingsDefault.yAxis, forKey: "yAxis")
        defaults.set(ChartSettingsDefault.yAxisGridLinesEnabled, forKey: "yAxisGridLinesEnabled")
        
        loadChartSettings()
    }
    
    func loadDashboardSettings() {
        let favouritesFirstTab = defaults.bool(forKey: "favouritesFirstTab")
        favouritesInitialTabSwitch.isOn = favouritesFirstTab
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
        if defaults.string(forKey: "marketSort") == "buy" {
            buySort.isSelected = true
            sellSort.isSelected = false
            
            buySort.backgroundColor = buttonHighlightedBackgroundColour
            sellSort.backgroundColor = UIColor.white
        }
        else if defaults.string(forKey: "marketSort") == "sell" {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.backgroundColor = UIColor.white
            sellSort.backgroundColor = buttonHighlightedBackgroundColour
        }
        
        if defaults.string(forKey: "marketOrder") == "ascending" {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.backgroundColor = buttonHighlightedBackgroundColour
            descendingSort.backgroundColor = UIColor.white
        }
        else if defaults.string(forKey: "marketOrder") == "descending" {
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
            
            defaults.set("buy", forKey: "marketSort")
        }
        else if (sender as! UIButton).isEqual(sellSort) {
            buySort.isSelected = false
            sellSort.isSelected = true
            
            buySort.backgroundColor = UIColor.white
            sellSort.backgroundColor = buttonHighlightedBackgroundColour
            
            defaults.set("sell", forKey: "marketSort")
        }
    }
    
    @IBAction func marketOrderButtonTapped(_ sender: Any) {
        if (sender as! UIButton).isEqual(ascendingSort) {
            ascendingSort.isSelected = true
            descendingSort.isSelected = false
            
            ascendingSort.backgroundColor = buttonHighlightedBackgroundColour
            descendingSort.backgroundColor = UIColor.white
            
            defaults.set("ascending", forKey: "marketOrder")
        }
        else if (sender as! UIButton).isEqual(descendingSort) {
            ascendingSort.isSelected = false
            descendingSort.isSelected = true
            
            ascendingSort.backgroundColor = UIColor.white
            descendingSort.backgroundColor = buttonHighlightedBackgroundColour
            
            defaults.set("descending", forKey: "marketOrder")
        }
    }
    
    func loadNewsSettings() {
        let newsSort = defaults.string(forKey: "newsSort")
        
        if newsSort == "popularity" {
            popularitySort.isSelected = true
            dateSort.isSelected = false
            
            popularitySort.backgroundColor = buttonHighlightedBackgroundColour
            dateSort.backgroundColor = UIColor.white
        }
        else if newsSort == "date" {
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
            
            defaults.set("popularity", forKey: "newsSort")
        }
        else if (sender as! UIButton).isEqual(dateSort) {
            popularitySort.isSelected = false
            dateSort.isSelected = true
            
            popularitySort.backgroundColor = UIColor.white
            dateSort.backgroundColor = buttonHighlightedBackgroundColour
            
            defaults.set("date", forKey: "newsSort")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let removeAdsPurchased: Bool = UserDefaults.standard.bool(forKey: "removeAdsPurchased")
        let unlockMarketsPurchased: Bool = UserDefaults.standard.bool(forKey: "unlockMarketsPurchased")
        let paidUser: Bool = UserDefaults.standard.bool(forKey: "paidUser")

        if indexPath.section == 0 { // in-app purchases
            if !paidUser {
                if !removeAdsPurchased {
                    if indexPath.row == 0 {
                        IAPService.shared.purchase(product: .removeAds, completionHandlerBool: { (success) -> Void in
                            
                        })
                    }
                }
                if !unlockMarketsPurchased {
                    if indexPath.row == 1 {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "UnlockMarketsViewController")
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
            if indexPath.row == 2 {
                IAPService.shared.restorePurchases()
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 1 { // Remove all favourites
                defaults.set([], forKey: "dashboardFavourites")
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
