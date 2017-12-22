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
    
    @IBOutlet weak var currentBtcPriceLabel: UILabel!
    @IBOutlet weak var currentBtcPriceView: UIView!
    @IBOutlet weak var lastUpdated: UILabel!

    @IBOutlet weak var btcPriceChangeLabel: UILabel!
    @IBOutlet weak var timeSpan: UILabel!
    @IBOutlet weak var rangeSegmentControlObject: UISegmentedControl!
    
    var parentControler: DashboardViewController!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    var currency: String! = ""
    
    var selectedCountry: String!
    let todaysDate = Date()
    
    var currentBtcPrice: Double! = 0.0
    
    var btcPriceCollectedData: [Double: Double] = [:]
    @IBOutlet weak var chart: CandleStickChartView!

    @IBAction func rangeSegmentedControl(_ sender: Any) {
        if let index = (sender as? UISegmentedControl)?.selectedSegmentIndex {
            getChartData(timeSpan: index)
//            if index == 0 { // day
//                self.timeSpan.text = "(1 hour)"
//            }
//            else if index == 1 { // week
//                self.timeSpan.text = "(3 hours)"
//            }
//            else if index == 2 { // month
//                self.timeSpan.text = "(12 hours)"
//            }
//            else if index == 3 { // year
//                self.timeSpan.text = "(1 day)"
//            }
//            else if index == 4 { // year
//                self.timeSpan.text = "(1 week)"
//            }
//            else if index == 5 { // year
//                self.timeSpan.text = "(1 month)"
//            }
//            else if index == 6 { // year
//                self.timeSpan.text = "(6 months)"
//            }
//            else if index == 7 { // year
//                self.timeSpan.text = "(1 year)"
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chart.delegate = self
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        numberFormatter.numberStyle = .currency
        
        if GlobalValues.currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if GlobalValues.currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
//        self.getCurrentBtcPrice()

        self.rangeSegmentControlObject.selectedSegmentIndex = 0
        
        self.currentBtcPriceLabel.adjustsFontSizeToFitWidth = true

        self.btcPriceChangeLabel.layer.masksToBounds = true
        self.btcPriceChangeLabel.layer.cornerRadius = 8
        
        print(databaseTableTitle)
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
                let currencyData = dict[GlobalValues.currency!] as? [String: Any]
                let oldBtcPrice = self.currentBtcPrice ?? 0
                self.currentBtcPrice = currencyData!["price"] as! Double
                let unixTime = currencyData!["timestamp"] as! Double
                self.btcPriceCollectedData[unixTime] = self.currentBtcPrice
                var colour: UIColor
                
                if self.currentBtcPrice > oldBtcPrice {
                   colour = self.greenColour
                }
                else if self.currentBtcPrice < oldBtcPrice {
                    colour = self.redColour
                }
                else {
                    colour = UIColor.black
                }
                
                GlobalValues.currentBtcPriceString = self.numberFormatter.string(from: NSNumber(value: self.currentBtcPrice))
                GlobalValues.currentBtcPrice = self.currentBtcPrice
                DispatchQueue.main.async {
                    self.currentBtcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: self.currentBtcPrice))
                    
                    UILabel.transition(with: self.currentBtcPriceLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
                        self.currentBtcPriceLabel.textColor = colour
                    }, completion: { finished in
                        UILabel.transition(with: self.currentBtcPriceLabel, duration: 1.5, options: .transitionCrossDissolve, animations: {
                            self.currentBtcPriceLabel.textColor = UIColor.black
                        }, completion: nil)
                    })

                    self.dateFormatter.dateFormat = "h:mm a"
//                    self.lastUpdated.text = self.dateFormatter.string(from: Date(timeIntervalSince1970: unixTime))
                }
            }
        })
        
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
    
    // order dictionary btc data according to date
    func orderBtcPriceData(startDate: Date, endDate: Date, btcPriceData: [String:Double]) -> ([String], [Double]) {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if btcPriceData.count == 1 {
            return ([(btcPriceData.first?.key)!], [(btcPriceData.first?.value)!])
        }
        var labels : [String] = []
        var values : [Double] = []
        
        var tempDate = startDate
        
        while tempDate <= endDate {
            let tempDateString = self.dateFormatter.string(from: tempDate)
            if let price = btcPriceData[tempDateString] {
                labels.append(tempDateString)
                values.append(price)
            }
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
        }
        
        return (labels, values)
    }
    
    func initializeChart(labels: [String], values: [Double]) {
        
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<values.count {
            let data = ChartDataEntry(x: Double(i), y: values[i])
            lineChartEntry.append(data)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Price") //Here we convert lineChartEntry to a LineChartDataSet
        
        let lineColor = UIColor.init(hex: "2980B9")
        line1.colors = [lineColor] //Sets the colour to blue
//        line1.colors = ChartColorTemplates.liberty()
        line1.drawCirclesEnabled = false
        line1.fillAlpha = 1
        line1.lineWidth = 3
        if ChartSettings.chartMode == "linear" {
            line1.mode = .linear
        }
        else if ChartSettings.chartMode == "smooth" {
            line1.mode = .cubicBezier
        }
        else if ChartSettings.chartMode == "stepped" {
            line1.mode = .stepped
        }
        
        let gradientColors = [lineColor.cgColor, UIColor.white.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        line1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        line1.drawFilledEnabled = false // Draw the Gradient
        
        line1.highlightEnabled = true
        line1.highlightColor = UIColor.black.withAlphaComponent(0.4)
        line1.highlightLineWidth = 1
        line1.setDrawHighlightIndicators(true)
        line1.drawHorizontalHighlightIndicatorEnabled = false
        
        let lineChartData = LineChartData() //This is the object that will be added to the chart
        
        lineChartData.addDataSet(line1) //Adds the line to the dataSet
        lineChartData.setDrawValues(false)
        
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = ChartSettings.yAxis
        chart.leftAxis.drawGridLinesEnabled = ChartSettings.yAxisGridLinesEnabled
        
        chart.xAxis.enabled = ChartSettings.xAxis
        chart.xAxis.drawLabelsEnabled = true
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = ChartSettings.xAxisGridLinesEnabled

        chart.pinchZoomEnabled = true
        chart.legend.enabled = false
        chart.chartDescription?.text = ""
        
        chart.data = lineChartData //finally - it adds the chart data to the chart and causes an update
        
        // popup value on highlight
        let marker: BalloonMarker = BalloonMarker(color: UIColor.init(hex: "2980B9"), font: UIFont.systemFont(ofSize: 11), textColor: UIColor.white, insets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        marker.minimumSize = CGSize(width: 50, height: 30)
        chart.marker = marker
        
        // reset chart zoom
        chart.fitScreen()
        // reset highlight value
        chart.highlightValue(nil)
        if ChartSettings.yAxis {
            chart.setExtraOffsets(left: 5, top: 0, right: 10, bottom: 0)
        }
        else {
            chart.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)
        }

        chart.data?.notifyDataChanged()
    }

    func reloadData() {
//        self.getCurrentBtcPrice()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        print(entry)
    }
    
}
