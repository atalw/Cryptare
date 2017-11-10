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

public struct GlobalValues {
    static var currency: String!
    static var currentBtcPrice: Double!
    static var currentBtcPriceString: String!
}

public struct ChartSettings {
    static var chartMode: String! = UserDefaults.standard.string(forKey: "chartMode")
    
    static var xAxis: Bool! = UserDefaults.standard.bool(forKey: "xAxis")
    static var xAxisGridLinesEnabled: Bool! = UserDefaults.standard.bool(forKey: "xAxisGridLinesEnabled")
    
    static var yAxis: Bool! = UserDefaults.standard.bool(forKey: "yAxis")
    static var yAxisGridLinesEnabled: Bool! = UserDefaults.standard.bool(forKey: "yAxisGridLinesEnabled")
}

public struct ChartSettingsDefault {
    static let chartMode: String! = "smooth"
    
    static let xAxis: Bool! = false
    static let xAxisGridLinesEnabled: Bool! = false
    
    static let yAxis: Bool! = false
    static let yAxisGridLinesEnabled: Bool! = false
}

class GraphViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var currentBtcPriceLabel: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    @IBOutlet weak var btcPriceChangeLabel: UILabel!
    @IBOutlet weak var timeSpan: UILabel!
    @IBOutlet weak var rangeSegmentControlObject: UISegmentedControl!
    
    var parentControler: DashboardViewController!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    var selectedCountry: String!
    let todaysDate = Date()
    
    var btcPrice = "0"
    var btcPriceChange = "0"
    var btcChangeColour : UIColor = UIColor.gray
    var currentBtcPrice: Double! {
        didSet {
            self.loadChartData()
        }
    }
    @IBOutlet weak var chart: LineChartView!

    @IBAction func rangeSegmentedControl(_ sender: Any) {
        if let index = (sender as? UISegmentedControl)?.selectedSegmentIndex {
            getChartData(timeSpan: index)
            if index == 0 { // day
                self.timeSpan.text = "(1 day)"
            }
            else if index == 1 { // week
                self.timeSpan.text = "(1 week)"
            }
            else if index == 2 { // month
                self.timeSpan.text = "(1 month)"
            }
            else if index == 3 { // year
                self.timeSpan.text = "(1 year)"
            }
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
        self.getCurrentBtcPrice()

        self.rangeSegmentControlObject.selectedSegmentIndex = 1
        
        self.btcPriceChangeLabel.layer.masksToBounds = true
        self.btcPriceChangeLabel.layer.cornerRadius = 8
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getChartData(timeSpan: Int) {
        dateFormatter.dateFormat = "YYYY-MM-dd"

        var startDate: Date = self.todaysDate
        let endDate: Date = self.todaysDate
        let endDateString = dateFormatter.string(from: endDate)
        var url: URL!
        
        if timeSpan == 0 {
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&for=yesterday")!
        }
        else if timeSpan == 1 { // week
            startDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(startDateString)&end=\(endDateString)")!
        }
        else if timeSpan == 2 { // month
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(startDateString)&end=\(endDateString)")!
        }
        else if timeSpan == 3 { // year
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(startDateString)&end=\(endDateString)")!
        }
        
        self.getAllTimeBtcData(url: url, completion: { success, btcPriceData in
            if (success) {
                var (labels, values) = self.orderBtcPriceData(startDate: startDate, endDate: endDate, btcPriceData: btcPriceData)
                if timeSpan == 0 {
                    values.append(self.currentBtcPrice)
                    labels.append(endDateString)
                    self.updatePriceChange(startPrice: values[0], endPrice: values[1])
                }
                else {
                    self.updatePriceChange(startPrice: values[0], endPrice: values[values.count-1])
                }
                self.initializeChart(labels: labels, values: values)
            }
        }  )
    }
    
    func loadChartData() {
        DispatchQueue.main.async {
            self.getChartData(timeSpan: self.rangeSegmentControlObject.selectedSegmentIndex)
        }
    }
    
    // get current actual price of bitcoin
    func getCurrentBtcPrice() {
        var url: URL!
        url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/\(GlobalValues.currency!).json")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = JSON(data: data)
            if let price = json["bpi"][GlobalValues.currency]["rate_float"].double {
                self.currentBtcPrice = price
                DispatchQueue.main.async {
                    self.currentBtcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: price))
                    self.currentBtcPriceLabel.adjustsFontSizeToFitWidth = true
                    self.dateFormatter.dateFormat = "h:mm a"
                    self.lastUpdated.text = self.dateFormatter.string(from: Date())
                }
            }
            else {
                print(json["bpi"][GlobalValues.currency]["rate_float"].error!)
            }
            GlobalValues.currentBtcPriceString = self.numberFormatter.string(from: NSNumber(value: self.currentBtcPrice))
            GlobalValues.currentBtcPrice = self.currentBtcPrice
        }
        task.resume()
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

    func getAllTimeBtcData(url: URL, completion: @escaping (_ success : Bool, _ btcPriceData: [String: Double]) -> ()) {
        var plotData = [Double]()
        var btcPriceData = [String: Double]()
        
        let url = url
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
                let prices = JSON(data: data)["bpi"].dictionary
                for (date, subJson):(String, JSON) in prices! {
                    // store data in dictionary and then sort data according to date because you should not rely on the order of JSON response
                    if let price = subJson.double {
                        plotData.append(price)
                        btcPriceData[date] = price
                    }
                }
                DispatchQueue.main.async {
                    completion(true, btcPriceData)
                }
            }
        }
        task.resume()
    }
    
    func updatePriceChange(startPrice: Double, endPrice: Double) {
        let change = endPrice - startPrice
        let percentage = change/startPrice * 100
        let roundedPercentage = Double(round(100*percentage)/100)
        DispatchQueue.main.async {
            if roundedPercentage > 0 {
                self.btcPriceChangeLabel.text = "+\(roundedPercentage)%  "
                self.btcPriceChangeLabel.backgroundColor = UIColor.init(hex: "#2ecc71")
            }
            else if roundedPercentage < 0 {
                self.btcPriceChangeLabel.text = "\(roundedPercentage)%  "
                self.btcPriceChangeLabel.backgroundColor = UIColor.init(hex: "#e74c3c")
            }
            else if roundedPercentage == 0 {
                self.btcPriceChangeLabel.text = "\(roundedPercentage)%  "
                self.btcPriceChangeLabel.backgroundColor = UIColor.init(hex: "#e74c3c")
            }
        }
    }
    
    func reloadData() {
        self.getCurrentBtcPrice()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        print(entry)
    }
    
}
