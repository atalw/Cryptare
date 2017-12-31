//
//  GraphViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import Firebase

class GraphViewController: UIViewController, ChartViewDelegate {
    
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var ref: DatabaseReference!
    var ltcRef: DatabaseReference!
    
    var databaseTableTitle: String!
    
    var parentControler: DashboardViewController!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    let decimalNumberFormatter = NumberFormatter()
    var currency: String! = ""
    
    var selectedCountry: String!
    let todaysDate = Date()
    
    var currentPrice: Double! = 0.0
    
    var coinData: [String: Any] = [:]
    
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinLogo: UIImageView!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    @IBOutlet weak var high24hrsLabel: UILabel!
    @IBOutlet weak var low24hrsLabel: UILabel!
    @IBOutlet weak var lastTradedMarketLabel: UILabel!
    
    @IBOutlet weak var volume24hrsCoinLabel: UILabel!
    @IBOutlet weak var volume24hrsFiatLabel: UILabel!
    @IBOutlet weak var lastTradedVolumeLabel: UILabel!
    
    @IBOutlet weak var rangeSegmentControlObject: UISegmentedControl!
    
    @IBOutlet weak var chart: CandleStickChartView!
    
    @IBOutlet weak var coinSupplyLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    
    @IBAction func rangeSegmentedControl(_ sender: Any) {
        if let index = (sender as? UISegmentedControl)?.selectedSegmentIndex {
            getChartData(timeSpan: index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chart.delegate = self
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        decimalNumberFormatter.numberStyle = .decimal
        
        
        coinNameLabel.adjustsFontSizeToFitWidth = true
        coinSymbolLabel.adjustsFontSizeToFitWidth = true
        currentPriceLabel.adjustsFontSizeToFitWidth = true
        lastUpdatedLabel.adjustsFontSizeToFitWidth = true
        percentageChangeLabel.adjustsFontSizeToFitWidth = true
        priceChangeLabel.adjustsFontSizeToFitWidth = true
        high24hrsLabel.adjustsFontSizeToFitWidth = true
        low24hrsLabel.adjustsFontSizeToFitWidth = true
        lastTradedVolumeLabel.adjustsFontSizeToFitWidth = true
        volume24hrsCoinLabel.adjustsFontSizeToFitWidth = true
        volume24hrsFiatLabel.adjustsFontSizeToFitWidth = true
        lastTradedVolumeLabel.adjustsFontSizeToFitWidth = true
        coinSupplyLabel.adjustsFontSizeToFitWidth = true
        marketCapLabel.adjustsFontSizeToFitWidth = true

        self.rangeSegmentControlObject.selectedSegmentIndex = 0
        
        currentPriceLabel.adjustsFontSizeToFitWidth = true
        
        ref = Database.database().reference().child(databaseTableTitle)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currency = GlobalValues.currency!
        
        self.chart.rightAxis.enabled = false
        self.chart.leftAxis.enabled = ChartSettings.yAxis
        self.chart.leftAxis.drawGridLinesEnabled = ChartSettings.yAxisGridLinesEnabled
        
        self.chart.xAxis.enabled = ChartSettings.xAxis
        self.chart.xAxis.drawLabelsEnabled = true
        self.chart.xAxis.labelPosition = .bottom
        self.chart.xAxis.drawGridLinesEnabled = ChartSettings.xAxisGridLinesEnabled
        
        self.chart.pinchZoomEnabled = true
        self.chart.legend.enabled = false
        self.chart.chartDescription?.enabled = false
        
        self.chart.autoScaleMinMaxEnabled = true
        
        self.loadChartData()
        
        ref.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                self.updateCoinDataStructure(dict: dict)
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.observe(.childChanged, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                self.updateCoinDataStructure(dict: dict)
            }
        })
        
        coinSymbolLabel.text = databaseTableTitle
        if databaseTableTitle == "IOT" {
            coinLogo.image = UIImage(named: "miota")
        }
        else {
            coinLogo.image = UIImage(named: databaseTableTitle.lowercased())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func updateCoinDataStructure(dict: [String: Any]) {
        self.coinData["rank"] = dict["rank"] as! Int
        self.coinData["name"] = dict["name"] as! String
        
        self.title = self.coinData["name"] as! String
        
        let currencyData = dict[GlobalValues.currency!] as? [String: Any]
        
        if self.coinData["oldPrice"] == nil {
            self.coinData["oldPrice"] = 0.0
        }
        else {
            self.coinData["oldPrice"] = self.coinData["currentPrice"]
        }
        self.coinData["currentPrice"] = currencyData!["price"] as! Double
        
        let volumeCoin = currencyData!["vol_24hrs_coin"] as! Double
        self.coinData["volume24hrsCoin"] = Double(round(1000*volumeCoin)/1000)
        self.coinData["volume24hrsFiat"] = currencyData!["vol_24hrs_fiat"] as! Double

        self.coinData["high24hrs"] = currencyData!["high_24hrs"] as! Double
        self.coinData["low24hrs"] = currencyData!["low_24hrs"] as! Double
        
        self.coinData["lastTradeMarket"] = currencyData!["last_trade_market"] as! String
        self.coinData["lastTradeVolume"] = currencyData!["last_trade_volume"] as! Double
        
        self.coinData["supply"] = currencyData!["supply"] as! Double
        self.coinData["marketcap"] = currencyData!["marketcap"] as! Double

        
        let percentage = currencyData!["change_24hrs_percent"] as! Double
        let roundedPercentage = Double(round(1000*percentage)/1000)
        self.coinData["percentageChange24hrs"] = roundedPercentage
        self.coinData["priceChange24hrs"] = currencyData!["change_24hrs_fiat"] as! Double
        self.coinData["timestamp"] = currencyData!["timestamp"] as! Double
        
        self.updateLabels()
    }
    
    func updateLabels() {
        
        DispatchQueue.main.async {
            let currentPrice = self.coinData["currentPrice"] as! Double
            let oldPrice = self.coinData["oldPrice"] as? Double ?? 0.0
            
            var colour: UIColor
            if  currentPrice > oldPrice {
                colour = self.greenColour
            }
            else if currentPrice < oldPrice {
                colour = self.redColour
            }
            else {
                colour = UIColor.black
            }
            
            self.coinNameLabel.text = self.coinData["name"] as! String
            
            self.currentPriceLabel.text = (self.coinData["currentPrice"] as! Double).asCurrency
            self.flashColourOnLabel(label: self.currentPriceLabel, colour: colour)
            
            self.dateFormatter.dateFormat = "h:mm a"
            let timestamp = self.coinData["timestamp"] as! Double
            self.lastUpdatedLabel.text =  self.dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
            
            var percentageChangeColour: UIColor
            let percentageChange = self.coinData["percentageChange24hrs"] as! Double
            
            if  percentageChange > 0 {
                percentageChangeColour = self.greenColour
            }
            else if percentageChange < 0 {
                percentageChangeColour = self.redColour
            }
            else {
                percentageChangeColour = UIColor.black
            }
            
            self.percentageChangeLabel.text = "\(percentageChange)%"
            self.priceChangeLabel.text = (self.coinData["priceChange24hrs"] as! Double).asCurrency
            self.percentageChangeLabel.textColor = percentageChangeColour
            self.priceChangeLabel.textColor = percentageChangeColour
            
            self.high24hrsLabel.text = (self.coinData["high24hrs"] as! Double).asCurrency
            self.low24hrsLabel.text = (self.coinData["low24hrs"] as! Double).asCurrency
            self.lastTradedMarketLabel.text = self.coinData["lastTradeMarket"] as! String
            
            let formattedVolumeCoin = self.decimalNumberFormatter.string(from: NSNumber(value: self.coinData["volume24hrsCoin"] as! Double))
            self.volume24hrsCoinLabel.text = "\(formattedVolumeCoin!) \(self.databaseTableTitle!)"
            self.volume24hrsFiatLabel.text = (self.coinData["volume24hrsFiat"] as! Double).asCurrency
            let formattedLastTradedVolume = self.decimalNumberFormatter.string(from: NSNumber(value: self.coinData["lastTradeVolume"] as! Double))
            self.lastTradedVolumeLabel.text = "\(formattedLastTradedVolume!) \(self.databaseTableTitle!)"
            
            let formattedSupply = self.decimalNumberFormatter.string(from: NSNumber(value: self.coinData["supply"] as! Double))
            self.coinSupplyLabel.text = "\(formattedSupply!) \(self.databaseTableTitle!)"
            self.marketCapLabel.text = (self.coinData["marketcap"] as! Double).asCurrency
        }
    }
    
    func flashColourOnLabel(label: UILabel, colour: UIColor) {
        UILabel.transition(with:  label, duration: 0.1, options: .transitionCrossDissolve, animations: {
            label.textColor = colour
        }, completion: { finished in
            UILabel.transition(with:  label, duration: 1.5, options: .transitionCrossDissolve, animations: {
                label.textColor = UIColor.black
            }, completion: nil)
        })
    }
    
    func getChartData(timeSpan: Int) {
        var url: URL!
        
        if timeSpan == 0 { // 1 hour
            let urlString = "https://min-api.cryptocompare.com/data/histominute?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=60&aggregrate=30"
            url = URL(string: urlString)!
        }
        else if timeSpan == 1 { // 6 hours
            let urlString = "https://min-api.cryptocompare.com/data/histominute?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=180"
            url = URL(string: urlString)!
        }
        else if timeSpan == 2 { // 12 hours
            let urlString = "https://min-api.cryptocompare.com/data/histohour?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=12"
            url = URL(string: urlString)!
        }
        else if timeSpan == 3 { // 1 day
            let urlString = "https://min-api.cryptocompare.com/data/histohour?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=24"
            url = URL(string: urlString)!
        }
        else if timeSpan == 4 { // 1 week
            let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=7"
            url = URL(string: urlString)!
        }
        else if timeSpan == 5 { // 1 month
            let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=30"
            url = URL(string: urlString)!
        }
        else if timeSpan == 6 { // 6 months
            let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=180"
            url = URL(string: urlString)!
        }
        else if timeSpan == 7 { // 1 year
            let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(currency!)&limit=365"
            url = URL(string: urlString)!
        }
        
        getHourlyHistorialData(url: url, completion: { success, chartData in
            if success {
                let set1 = CandleChartDataSet(values: chartData, label: "Data Set")
                set1.axisDependency = .left
                set1.setColor(UIColor(white: 80/255, alpha: 1))
                set1.drawIconsEnabled = false
                set1.shadowColor = .lightGray
                set1.shadowWidth = 1
                set1.decreasingColor = self.redColour
                set1.decreasingFilled = true
                set1.increasingColor = self.greenColour
                set1.increasingFilled = true
                set1.neutralColor = .blue
                
                set1.drawValuesEnabled = false
                
                let data = CandleChartData(dataSet: set1)
                self.chart.data = data
            }
        })
        return
    }
    
    func getHourlyHistorialData(url: URL, completion: @escaping (_ success : Bool, _ chartData: [CandleChartDataEntry]) -> ()) {
        
        var chartData: [CandleChartDataEntry] = []
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                let prices = JSON(data: data)["Data"].arrayValue
                var index = 1
                for hour in prices {
                    let time = hour["time"].double
                    let high = hour["high"].double
                    let low = hour["low"].double
                    let open = hour["open"].double
                    let close = hour["close"].double
                    chartData.append(CandleChartDataEntry(x: Double(index), shadowH: high!, shadowL: low!, open: open!, close: close!))
                    index = index + 1
                }
                
                DispatchQueue.main.async {
                    completion(true, chartData)
                }
            }
        }
        task.resume()
        
    }
    
    func loadChartData() {
        DispatchQueue.main.async {
            self.getChartData(timeSpan: self.rangeSegmentControlObject.selectedSegmentIndex)
        }
    }
}
