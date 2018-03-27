//
//  PortfolioSummaryViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class PortfolioSummaryViewController: UIViewController {
    
    var portfolioName: String!
    var portfolioData: [String: [[String: Any]] ]!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")

    let portfolioEntriesConstant = "portfolioEntries"
    let fiatPortfolioEntriesConstant = "fiatPortfolioEntries"

    var dict: [String: [[String: Any]] ] = [:]
    var currencyDict: [String: [[String: Any]]] = [:]

    var summary: [String: [String: Double] ] = [:]
    var yesterdayCoinValues: [String: Double] = [:]
    
    var coins: [String] = []
    var currencies: [String] = []

    var databaseRef: DatabaseReference!
    var coinRefs: [DatabaseReference] = []
    
    @IBOutlet weak var option24hrButton: UIButton!
    @IBOutlet weak var optionAllTimeButton: UIButton!
    
    @IBOutlet weak var currentPortfolioValueLabel: UILabel!
    @IBOutlet weak var totalInvestedLabel: UILabel!
    @IBOutlet weak var totalPercentageChangeLabel: UILabel!
    @IBOutlet weak var totalPriceChangeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        timeFormatter.dateFormat = "hh:mm a"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        yesterdayCoinValues = [:]
        
        option24hrButton.isSelected = true
        optionAllTimeButton.isSelected = false
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        
        loadAllPortfolios(portfolioData: portfolioData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if coins.count == 0 {
            tableView.reloadData()
//            updateSummaryLabels(portfolioName: portfolioName)
            let messageLabel = UILabel()
            messageLabel.text = "Add a coin"
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
        }
        else {
            tableView.backgroundView = nil

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if coins.count == 0 && currencies.count == 0 {
            tableViewHeightConstraint.constant = 500
        }
        else {
            tableViewHeightConstraint.constant = tableView.contentSize.height
            tableView.reloadData()
        }

    }
    
    override func viewDidLayoutSubviews() {
        if coins.count == 0 && currencies.count == 0 {
            tableViewHeightConstraint.constant = 500
        }
        else {
            tableViewHeightConstraint.constant = tableView.contentSize.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        databaseRef.removeAllObservers()
        
        for coinRef in coinRefs {
            coinRef.removeAllObservers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVc = segue.destination
        if let addCoinVc = destinationVc as? AddCoinTableViewController {
            addCoinVc.parentController = self
        }
        else if let cryptoPortfolioVC = destinationVc as? CryptoPortfolioViewController {
            cryptoPortfolioVC.parentController = self
        }
    }
    
    func loadAllPortfolios(portfolioData: [String: [[String: Any]]]) {
        databaseRef = Database.database().reference()

        dict = [:]
        currencyDict = [:]
        
        coins = []
        currencies = []
        
        summary = [:]
        
        initalizePortfolioEntries(portfolioData: portfolioData)

    }
    
    func calculateCostFromDate(dateString: String, completionHandler: @escaping (Double) -> ()) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        let unixTime = Int((date?.timeIntervalSince1970)!)
        let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=BTC&tsyms=\(GlobalValues.currency!)&ts=\(unixTime)")!
        Alamofire.request(url).responseJSON(completionHandler: { response in
            
            let json = JSON(data: response.data!)
            if let price = json["BTC"][GlobalValues.currency!].double {
                completionHandler(price)
            }
        })
    }
    
    func initalizePortfolioEntries(portfolioData: [String: [[String: Any]]]) {
        dateFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
        dict = [:]
        dict = portfolioData
        
        for coin in dict.keys {
            coins.append(coin)
        }
        
        if let data = defaults.data(forKey: fiatPortfolioEntriesConstant) {
            let portfolioEntries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int:Any]]
            
            currencyDict = [:]
            for index in 0..<portfolioEntries.count {
                if portfolioEntries[index].count == 7 { // fiat currency entry
                    let firstElement = portfolioEntries[index][0] as? String // currency
                    let secondElement = portfolioEntries[index][1] as? String // transaction type
                    let thirdElement = portfolioEntries[index][2] as? String // exchange
                    let fourthElement = portfolioEntries[index][3] as? Double // amount
                    let fifthElement = portfolioEntries[index][4] as? Double // fees
                    let sixthElement = portfolioEntries[index][5] as? Date // date
                    let seventhElement = portfolioEntries[index][6] as? Date // time
                    
                    if let currency = firstElement,
                        let type = secondElement,
                        let exchange = thirdElement,
                        let amount = fourthElement,
                        let fees = fifthElement,
                        let date = sixthElement,
                        let time = seventhElement {
                        
                        if currencyDict[currency] == nil {
                            currencyDict[currency] = []
                        }
                        
                        currencyDict[currency]!.append(["type": type,
                                                        "exchange": exchange,
                                                        "amount": amount,
                                                        "fees": fees,
                                                        "date": date
                            ])
                    }
                    
                }
            }
            print(currencyDict)
            for currency in currencyDict.keys {
                currencies.append(currency)
            }
        }
        
        calculatePortfolioSummary(portfolioName: portfolioName, dict: dict)

    }
    
    func calculatePortfolioSummary(portfolioName: String, dict: [String: [[String: Any]] ]) {
        
        for (coin, transactions) in dict {
            summary[coin] = [:]
            summary[coin]!["amountOfCoins"] = 0.0
            summary[coin]!["costPerCoin"] = 0.0
            summary[coin]!["totalCost"] = 0.0
            summary[coin]!["coinMarketValue"] = 0.0 // market value of 1 coin
            summary[coin]!["holdingsMarketValue"] = 0.0 // market value of holdings
            summary[coin]!["coinValueYesterday"] = 0.0
            summary[coin]!["holdingsValueYesterday"] = 0.0
            
            for trans in transactions {
                let amount = (trans["amountOfCoins"] as! Double) * (trans["costPerCoin"] as! Double) - (trans["fees"] as! Double)

                if trans["type"] as! String == "buy" {
                   summary[coin]!["amountOfCoins"] = summary[coin]!["amountOfCoins"]! + (trans["amountOfCoins"] as! Double)
                    summary[coin]!["costPerCoin"] = summary[coin]!["costPerCoin"]! + (trans["costPerCoin"] as! Double)
                    summary[coin]!["totalCost"] =  summary[coin]!["totalCost"]! + amount
                }
                else if trans["type"] as! String == "sell" {
                    summary[coin]!["amountOfCoins"] = summary[coin]!["amountOfCoins"]! - (trans["amountOfCoins"] as! Double)
                    summary[coin]!["costPerCoin"] = summary[coin]!["costPerCoin"]! - (trans["costPerCoin"] as! Double)
                    summary[coin]!["totalCost"] =  summary[coin]!["totalCost"]! - amount

                }
            }
            
            coinRefs.append(databaseRef.child(coin))
            let index = coinRefs.count - 1
            
            coinRefs[index].observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let price = dict[GlobalValues.currency!]!["price"] as! Double
                    self.summary[coin]!["coinMarketValue"] = price
                    self.summary[coin]!["holdingsMarketValue"] = self.summary[coin]!["amountOfCoins"]! * self.summary[coin]!["coinMarketValue"]!
//                    self.dict[coin]?.append([])
                    self.updateSummaryLabels()
                    self.tableView.reloadData()
                }
            })
        }
        
        for currency in currencyDict.keys {
            summary[currency] = [:]
            summary[currency]!["amount"] = 0.0
            summary[currency]!["deposited"] = 0.0
            
            for entry in currencyDict[currency]! {
                var entryAmount = entry["amount"] as! Double
                var fees = entry["fees"] as! Double
                
                if entry["type"] as! String == "deposit" {
                    summary[currency]!["amount"] = summary[currency]!["amount"]! + entryAmount - fees
                    summary[currency]!["deposited"] = summary[currency]!["deposited"]! + entryAmount - fees
                }
                else if entry["type"] as! String == "withdraw" {
                    summary[currency]!["amount"] = summary[currency]!["amount"]! - entryAmount - fees
                }
            }
        }
        getCoinValueYesterday()
    }
    
    func getCoinValueYesterday() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Int(Date().timeIntervalSince1970 - (24*60*60))
        for coin in coins {
            let url = URL(string: "https://min-api.cryptocompare.com/data/pricehistorical?fsym=\(coin)&tsyms=\(GlobalValues.currency!)&ts=\(yesterday)")!
            
            Alamofire.request(url).responseJSON(completionHandler: { response in
                
                let json = JSON(data: response.data!)
                if let price = json[coin][GlobalValues.currency!].double {
                    self.summary[coin]!["coinValueYesterday"] = price
                    self.summary[coin]!["holdingsValueYesterday"] = price * self.summary[coin]!["amountOfCoins"]!
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func updateSummaryLabels() {
        var currentPortfolioValue = 0.0
        var totalInvested = 0.0
        var yesterdayPortfolioValue = 0.0
        
        currentPortfolioValueLabel.text = 0.asCurrency
        totalInvestedLabel.text = 0.asCurrency
        
        totalPercentageChangeLabel.text = "\(0.00) %"
        totalPriceChangeLabel.text = 0.asCurrency
        
        for coin in coins {
            currentPortfolioValue = currentPortfolioValue + summary[coin]!["holdingsMarketValue"]!
            totalInvested = totalInvested + summary[coin]!["totalCost"]!
            yesterdayPortfolioValue = yesterdayPortfolioValue + summary[coin]!["holdingsValueYesterday"]!
        }
        
        for currency in currencies {
            currentPortfolioValue = currentPortfolioValue + summary[currency]!["amount"]!
            yesterdayPortfolioValue = yesterdayPortfolioValue + summary[currency]!["amount"]!
        }
        
        var priceChange: Double = 0
        var percentageChange: Double = 0
        
        if option24hrButton.isSelected {
            priceChange = currentPortfolioValue - yesterdayPortfolioValue
            percentageChange = priceChange / yesterdayPortfolioValue * 100
        }
        else if optionAllTimeButton.isSelected {
            priceChange = currentPortfolioValue - totalInvested
            percentageChange = priceChange / totalInvested * 100
        }
        
        var colour: UIColor
        
        if percentageChange > 0 {
            colour = greenColour
        }
        else if percentageChange < 0 {
            colour = redColour
        }
        else {
            colour = UIColor.black
        }
        
        currentPortfolioValueLabel.text = currentPortfolioValue.asCurrency
        totalInvestedLabel.text = totalInvested.asCurrency
        
        if !percentageChange.isNaN && !percentageChange.isInfinite {
            let roundedPercentageChange = Double(round(percentageChange*100)/100)
            
            totalPercentageChangeLabel.text = "\(roundedPercentageChange) %"
            totalPriceChangeLabel.text = priceChange.asCurrency
            
            totalPercentageChangeLabel.textColor = colour
            totalPriceChangeLabel.textColor = colour
        }
        
    }
    
    @IBAction func optionAllTimeTapped(_ sender: Any) {
        optionAllTimeButton.isSelected = true
        option24hrButton.isSelected = false
        updateSummaryLabels()
        tableView.reloadData()
    }
    
    @IBAction func option24hrTapped(_ sender: Any) {
        optionAllTimeButton.isSelected = false
        option24hrButton.isSelected = true
        updateSummaryLabels()
        tableView.reloadData()
    }
    
    
}

extension PortfolioSummaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if dict.count > 0 && currencyDict.count > 0 {
            return 2
        }
        else if (dict.count == 0 && currencyDict.count > 0) || (dict.count > 0 && currencyDict.count == 0) {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && dict.count > 0 {
            return "Cryptocurrencies"
        }
        else {
            return "Fiat currencies"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == 0 && dict.count > 0 {
            count = dict.count
        }
        else {
            count = currencyDict.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        updateSummaryLabels()
        
        if indexPath.section == 0 && dict.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioSummaryCell") as? PortfolioSummaryTableViewCell
            
            let coin = coins[indexPath.row]
            
            cell!.coinSymbolLabel.text = "\(coin)"
            cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
            
            if coin == "IOT" {
                cell!.coinImage.image = UIImage(named: "miota")
            }
            else {
                cell!.coinImage.image = UIImage(named: coin.lowercased())
            }
            for (symbol, name) in GlobalValues.coins {
                if symbol == coin {
                    cell!.coinNameLabel.text = name
                }
            }
            
            cell!.coinHoldingsLabel.text = "\(summary[coin]!["amountOfCoins"]!) \(coin)"
            cell!.coinHoldingsLabel.adjustsFontSizeToFitWidth = true
            
            let holdingsMarketValue = summary[coin]!["holdingsMarketValue"]!
            cell!.coinCurrentValueLabel.text = holdingsMarketValue.asCurrency
            cell!.coinCurrentValueLabel.adjustsFontSizeToFitWidth = true
            
            var percentageChange: Double! = 0
            var priceChange: Double! = 0
            
            if option24hrButton.isSelected {
                let holdingsValueYesterday = summary[coin]!["holdingsValueYesterday"]!
                priceChange = holdingsMarketValue - holdingsValueYesterday
                
                percentageChange = priceChange / holdingsValueYesterday * 100
            }
            else if optionAllTimeButton.isSelected {
                let totalCost = summary[coin]!["totalCost"]!
                priceChange = holdingsMarketValue - totalCost
                
                percentageChange = priceChange / totalCost * 100
            }
            
            
            var colour: UIColor
            
            if percentageChange > 0 {
                colour = greenColour
            }
            else if percentageChange < 0 {
                colour = redColour
            }
            else {
                colour = UIColor.black
            }
            
            if !percentageChange.isNaN && !percentageChange.isInfinite {
                let roundedPercentage = Double(round(percentageChange*100)/100)
                
                cell!.changePercentageLabel.text = "\(roundedPercentage) %"
                cell!.changeCostLabel.text = priceChange.asCurrency
                
                cell!.changePercentageLabel.textColor = colour
                cell!.changeCostLabel.textColor = colour
            }
            
            cell!.changePercentageLabel.adjustsFontSizeToFitWidth = true
            cell!.changeCostLabel.adjustsFontSizeToFitWidth = true
            
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioFiatSummaryCell") as! PortfolioFiatSummaryTableViewCell
            
            let currency = currencies[indexPath.row]
            
            cell.currencyLogoImage.image = UIImage(named: currency.lowercased())
            cell.currencySymbolLabel.text = currency
            
            for (country, symbol, locale, name) in GlobalValues.countryList {
                if symbol == currency {
                    cell.currencyNameLabel.text = name
                }
            }
            
            if let holdingsMarketValue = summary[currency]?["amount"] {
                cell.holdingsLabel.text = holdingsMarketValue.asCurrency
                cell.holdingsLabel.adjustsFontSizeToFitWidth = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if section == 0 && dict.count > 0 {
            let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! CryptoPortfolioViewController
            
            let coin = coins[indexPath.row]
            targetViewController.coin = coin
            targetViewController.portfolioName = portfolioName
            targetViewController.portfolioData = dict[coin]!
            targetViewController.coinPrice = self.summary[coin]!["coinMarketValue"]
            targetViewController.parentController = self
            
            self.navigationController?.pushViewController(targetViewController, animated: true)
        }
        else {
            let targetViewController = storyboard?.instantiateViewController(withIdentifier: "fiatPortfolioViewController") as! FiatPortfolioViewController
            
            let currency = currencies[indexPath.row]
            targetViewController.currency = currency
            targetViewController.portfolioData = currencyDict[currency]!
            targetViewController.parentController = self

            self.navigationController?.pushViewController(targetViewController, animated: true)
        }
    }
    
    func newCoinAdded(coin: String) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! CryptoPortfolioViewController
        
        var handle = databaseRef.child(coin).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                let price = dict[GlobalValues.currency!]!["price"] as! Double
                targetViewController.coinPrice = price
            }
        })
        
        targetViewController.coin = coin
        targetViewController.parentController = self
        if let data = dict[coin] {
            targetViewController.portfolioData = data
        }
        else {
            targetViewController.portfolioData = []
        }
//        handle.remo
        self.navigationController?.pushViewController(targetViewController, animated: true)
    }
    
    func newCurrencyAdded(currency: String) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "fiatPortfolioViewController") as! FiatPortfolioViewController
        
        targetViewController.currency = currency
        targetViewController.parentController = self

        if let data = currencyDict[currency] {
            targetViewController.portfolioData = data
        }
        else {
            targetViewController.portfolioData = []
        }
        
        self.navigationController?.pushViewController(targetViewController, animated: true)
    }
}
