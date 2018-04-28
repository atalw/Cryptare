//
//  CryptoDetailViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 03/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import Firebase
import SwiftyUserDefaults

class CryptoDetailViewController: UIViewController, ChartViewDelegate {
  
  let greenColour = UIColor.init(hex: "#2ecc71")
  let redColour = UIColor.init(hex: "#e74c3c")
  
  var ref: DatabaseReference!
  
  var databaseTableTitle: String!
  
  var parentControler: DashboardViewController!
  
  let dateFormatter = DateFormatter()
  let decimalNumberFormatter = NumberFormatter()
  var currency: String! = ""
  
  var selectedCountry: String!
  let todaysDate = Date()
  
  var currentPrice: Double! = 0.0
  
  var coinData: [String: Any] = [:]
  
  @IBOutlet weak var coinNameLabel: UILabel! {
    didSet {
      coinNameLabel.adjustsFontSizeToFitWidth = true
      coinNameLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var coinLogo: UIImageView! {
    didSet {
      
    }
  }
  
  @IBOutlet weak var coinSymbolLabel: UILabel! {
    didSet {
      coinSymbolLabel.adjustsFontSizeToFitWidth = true
      coinSymbolLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var currentPriceLabel: UILabel! {
    didSet {
      currentPriceLabel.adjustsFontSizeToFitWidth = true
      currentPriceLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var lastUpdatedLabel: UILabel! {
    didSet {
      lastUpdatedLabel.adjustsFontSizeToFitWidth = true
      lastUpdatedLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var percentageChangeLabel: UILabel! {
    didSet {
      percentageChangeLabel.adjustsFontSizeToFitWidth = true
    }
  }
  
  @IBOutlet weak var priceChangeLabel: UILabel! {
    didSet {
      priceChangeLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var separatorView: UIView! {
    didSet {
      separatorView.theme_backgroundColor = GlobalPicker.tableSeparatorColor
    }
  }
  
  @IBOutlet weak var high24hrsLabel: UILabel! {
    didSet {
      high24hrsLabel.adjustsFontSizeToFitWidth = true
      high24hrsLabel.theme_textColor = GlobalPicker.viewTextColor
    }
  }
  
  @IBOutlet weak var low24hrsLabel: UILabel! {
    didSet {
      low24hrsLabel.adjustsFontSizeToFitWidth = true
      low24hrsLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var lastTradedMarketLabel: UILabel! {
    didSet {
      lastTradedMarketLabel.adjustsFontSizeToFitWidth = true
      lastTradedMarketLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var volume24hrsCoinLabel: UILabel! {
    didSet {
      volume24hrsCoinLabel.adjustsFontSizeToFitWidth = true
      volume24hrsCoinLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var volume24hrsFiatLabel: UILabel! {
    didSet {
      volume24hrsFiatLabel.adjustsFontSizeToFitWidth = true
      volume24hrsFiatLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var lastTradedVolumeLabel: UILabel! {
    didSet {
      lastTradedVolumeLabel.adjustsFontSizeToFitWidth = true
      lastTradedVolumeLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var rangeSegmentControlObject: UISegmentedControl! {
    didSet {
      rangeSegmentControlObject.selectedSegmentIndex = 0
      rangeSegmentControlObject.theme_tintColor = GlobalPicker.segmentControlTintColor
      
    }
  }
  
  @IBOutlet weak var chart: CandleStickChartView! {
    didSet {
      let selectedIndex = Defaults[.currentThemeIndex]
      if selectedIndex == 0 {
        //                chart.xAxis.gridColor
        
      }
      else if selectedIndex == 1 {
        chart.xAxis.gridColor = UIColor.init(hex: "6c8298")
        chart.xAxis.labelTextColor = UIColor.white
        chart.leftAxis.gridColor = UIColor.init(hex: "6c8298")
        chart.leftAxis.labelTextColor = UIColor.white
      }
    }
  }
  
  @IBOutlet weak var coinSupplyLabel: UILabel! {
    didSet {
      coinSupplyLabel.adjustsFontSizeToFitWidth = true
      coinSupplyLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBOutlet weak var marketCapLabel: UILabel! {
    didSet {
      marketCapLabel.adjustsFontSizeToFitWidth = true
      marketCapLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  
  @IBAction func rangeSegmentedControl(_ sender: Any) {
    if let index = (sender as? UISegmentedControl)?.selectedSegmentIndex {
      getChartData(timeSpan: index)
    }
  }
  
  @IBOutlet weak var highDescLabel: UILabel! {
    didSet {
      highDescLabel.adjustsFontSizeToFitWidth = true
      highDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var lowDescLabel: UILabel! {
    didSet {
      lowDescLabel.adjustsFontSizeToFitWidth = true
      lowDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var lastMarketDescLabel: UILabel! {
    didSet {
      lastMarketDescLabel.adjustsFontSizeToFitWidth = true
      lastMarketDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var volumePriceDescLabel: UILabel! {
    didSet {
      volumePriceDescLabel.adjustsFontSizeToFitWidth = true
      volumePriceDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var volumePercDescLabel: UILabel! {
    didSet {
      volumePercDescLabel.adjustsFontSizeToFitWidth = true
      volumePercDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var lastVolumeDescLabel: UILabel! {
    didSet {
      lastVolumeDescLabel.adjustsFontSizeToFitWidth = true
      lastVolumeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var supplyDescLabel: UILabel! {
    didSet {
      supplyDescLabel.adjustsFontSizeToFitWidth = true
      supplyDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var marketCapDescLabel: UILabel! {
    didSet {
      marketCapDescLabel.adjustsFontSizeToFitWidth = true
      marketCapDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Analytics.setScreenName("Crypto Details", screenClass: "CryptoDetailViewController")
    
    
    self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    
    self.chart.delegate = self
    
    self.selectedCountry = Defaults[.selectedCountry]
    
    dateFormatter.dateFormat = "YYYY-MM-dd"
    decimalNumberFormatter.numberStyle = .decimal
    
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
    
    //    ref.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
    //      if let dict = snapshot.value as? [String : AnyObject] {
    //        self.updateCoinDataStructure(dict: dict)
    //      }
    //    })
    updateLabels()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    coinSymbolLabel.text = databaseTableTitle
    coinLogo.loadSavedImage(coin: databaseTableTitle)
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    ref.removeAllObservers()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //  func updateCoinDataStructure(dict: [String: Any]) {
  //    self.coinData["rank"] = dict["rank"] as! Int
  //    self.coinData["name"] = dict["name"] as! String
  //
  //    self.title = self.coinData["name"] as! String
  //
  //    let currencyData = dict[GlobalValues.currency!] as? [String: Any]
  //
  //    if self.coinData["oldPrice"] == nil {
  //      self.coinData["oldPrice"] = 0.0
  //    }
  //    else {
  //      self.coinData["oldPrice"] = self.coinData["currentPrice"]
  //    }
  //    self.coinData["currentPrice"] = currencyData!["price"] as! Double
  //
  //    let volumeCoin = currencyData!["vol_24hrs_coin"] as! Double
  //    self.coinData["volume24hrsCoin"] = Double(round(1000*volumeCoin)/1000)
  //    self.coinData["volume24hrsFiat"] = currencyData!["vol_24hrs_fiat"] as! Double
  //
  //    self.coinData["high24hrs"] = currencyData!["high_24hrs"] as! Double
  //    self.coinData["low24hrs"] = currencyData!["low_24hrs"] as! Double
  //
  //    self.coinData["lastTradeMarket"] = currencyData!["last_trade_market"] as! String
  //    self.coinData["lastTradeVolume"] = currencyData!["last_trade_volume"] as! Double
  //
  //    self.coinData["supply"] = currencyData!["supply"] as! Double
  //    self.coinData["marketcap"] = currencyData!["marketcap"] as! Double
  //
  //
  //    let percentage = currencyData!["change_24hrs_percent"] as! Double
  //    let roundedPercentage = Double(round(1000*percentage)/1000)
  //    self.coinData["percentageChange24hrs"] = roundedPercentage
  //    self.coinData["priceChange24hrs"] = currencyData!["change_24hrs_fiat"] as! Double
  //    self.coinData["timestamp"] = currencyData!["timestamp"] as! Double
  //
  //    self.updateLabels()
  //  }
  
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
      if colour != UIColor.black {
        self.flashColourOnLabel(label: self.currentPriceLabel, colour: colour)
      }
      
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
      
      if let high24hrs = self.coinData["high24hrs"] as? Double {
        self.high24hrsLabel.text = high24hrs.asCurrency
      }
      else {
        self.high24hrsLabel.text = "NA"
      }
      
      if let low24hrs = self.coinData["low24hrs"] as? Double {
        self.low24hrsLabel.text = low24hrs.asCurrency
      }
      else {
        self.low24hrsLabel.text = "NA"
      }
      
      if let lastTradeMarket = self.coinData["lastTradeMarket"] as? String {
        self.lastTradedMarketLabel.text = lastTradeMarket
      }
      else {
        self.lastTradedMarketLabel.text = "NA"
      }
      
      if let volumeCoin = self.coinData["volume24hrsCoin"] as? Double {
        let formattedVolumeCoin = self.decimalNumberFormatter.string(from: NSNumber(value: volumeCoin))
        self.volume24hrsCoinLabel.text = "\(formattedVolumeCoin!) \(self.databaseTableTitle!)"
      }
      else {
        self.volume24hrsCoinLabel.text = "NA"
      }
      
      if let volumeFiat = self.coinData["volume24hrs"] as? Double {
        self.volume24hrsFiatLabel.text = volumeFiat.asCurrency
      }
      else {
        self.volume24hrsFiatLabel.text = "NA"
      }
      
      if let lastTradeVolume = self.coinData["lastTradeVolume"] as? Double {
        let formattedLastTradedVolume = self.decimalNumberFormatter.string(from: NSNumber(value: lastTradeVolume))
        self.lastTradedVolumeLabel.text = "\(formattedLastTradedVolume!) \(self.databaseTableTitle!)"
      }
      else {
        self.lastTradedVolumeLabel.text = "NA"
      }
      
      if let supply = self.coinData["supply"] as? Double {
        let formattedSupply = self.decimalNumberFormatter.string(from: NSNumber(value: supply))
        self.coinSupplyLabel.text = "\(formattedSupply!) \(self.databaseTableTitle!)"
      }
      else {
        self.coinSupplyLabel.text = "NA"
      }
      
      if let marketcap = self.coinData["marketcap"] as? Double {
        self.marketCapLabel.text = marketcap.asCurrency
      }
      else {
        self.marketCapLabel.text = "NA"
      }
    }
  }
  
  func flashColourOnLabel(label: UILabel, colour: UIColor) {
    UILabel.transition(with:  label, duration: 0.1, options: .transitionCrossDissolve, animations: {
      label.textColor = colour
    }, completion: { finished in
      UILabel.transition(with:  label, duration: 1.5, options: .transitionCrossDissolve, animations: {
        label.theme_textColor = GlobalPicker.viewTextColor
      }, completion: nil)
    })
  }
  
  func getChartData(timeSpan: Int) {
    var url: URL!
    
    var scopeCurrency : String = currency
    if currency! == "INR" || currency! == "CAD" || currency! == "GBP" {
      scopeCurrency = "USD"
    }
    
    if timeSpan == 0 { // 1 hour
      let urlString = "https://min-api.cryptocompare.com/data/histominute?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=60&aggregrate=30"
      url = URL(string: urlString)!
    }
    else if timeSpan == 1 { // 6 hours
      let urlString = "https://min-api.cryptocompare.com/data/histominute?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=180"
      url = URL(string: urlString)!
    }
    else if timeSpan == 2 { // 12 hours
      let urlString = "https://min-api.cryptocompare.com/data/histohour?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=12"
      url = URL(string: urlString)!
    }
    else if timeSpan == 3 { // 1 day
      let urlString = "https://min-api.cryptocompare.com/data/histohour?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=24"
      url = URL(string: urlString)!
    }
    else if timeSpan == 4 { // 1 week
      let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=7"
      url = URL(string: urlString)!
    }
    else if timeSpan == 5 { // 1 month
      let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=30"
      url = URL(string: urlString)!
    }
    else if timeSpan == 6 { // 6 months
      let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=180"
      url = URL(string: urlString)!
    }
    else if timeSpan == 7 { // 1 year
      let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(databaseTableTitle!)&tsym=\(scopeCurrency)&limit=365"
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
    var exchangeRate: Double = 1
    
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
        if self.currency == "INR" || self.currency == "CAD" || self.currency == "GBP" {
          let exchangeURL = URL(string: "https://api.fixer.io/latest?symbols=\(self.currency!)&base=USD")!
          let exchangeTask = URLSession.shared.dataTask(with: exchangeURL) { data, response, error in
            guard error == nil else {
              return
            }
            guard let data = data else {
              return
            }
            do {
              exchangeRate = JSON(data:data)["rates"][self.currency!].double!
              
              for hour in prices {
                let time = hour["time"].double! * exchangeRate
                let high = hour["high"].double! * exchangeRate
                let low = hour["low"].double! * exchangeRate
                let open = hour["open"].double! * exchangeRate
                let close = hour["close"].double! * exchangeRate
                chartData.append(CandleChartDataEntry(x: Double(index), shadowH: high, shadowL: low, open: open, close: close))
                index = index + 1
              }
              
              DispatchQueue.main.async {
                completion(true, chartData)
              }
            }
          }
          exchangeTask.resume()
        }
        else {
          for hour in prices {
            let time = hour["time"].double!
            let high = hour["high"].double!
            let low = hour["low"].double!
            let open = hour["open"].double!
            let close = hour["close"].double!
            chartData.append(CandleChartDataEntry(x: Double(index), shadowH: high, shadowL: low, open: open, close: close))
            index = index + 1
          }
          
          DispatchQueue.main.async {
            completion(true, chartData)
          }
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
