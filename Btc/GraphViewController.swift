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

class GraphViewController: UIViewController  {
    
    @IBOutlet weak var currentBtcPriceLabel: UILabel!
    @IBOutlet weak var btcPriceChangeLabel: UILabel!
    @IBOutlet weak var timeSpan: UILabel!
    @IBOutlet weak var rangeSegmentControlObject: UISegmentedControl!
    
    let defaults = UserDefaults.standard
    var selectedCountry: String!
    var currency: String! = "INR" // set default value to INR

    let dateFormatter = DateFormatter()
    let todaysDate = Date()
    
    @IBAction func rangeSegmentedControl(_ sender: Any) {
        let index = (sender as? UISegmentedControl)?.selectedSegmentIndex
        
        var startDate: Date = self.todaysDate
        let endDate: Date = self.todaysDate
        let endDateString = dateFormatter.string(from: endDate)
        var url: URL!
        
//        if index == 0 { // day
//            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=2017-09-01&end=2017-09-08")!
//        }
        if index == 0 { // week
            startDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(currency!)&start=\(startDateString)&end=\(endDateString)")!
            self.timeSpan.text = "(1 week)"
        }
        else if index == 1 { // month
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(currency!)&start=\(startDateString)&end=\(endDateString)")!
            self.timeSpan.text = "(1 month)"
        }        else if index == 2 { // year
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(currency!)&start=\(startDateString)&end=\(endDateString)")!
            self.timeSpan.text = "(1 year)"
        }
        self.getAllTimeBtcData(url: url, completion: { success, btcPriceData in
            if (success) {
                let (labels, values) = self.orderBtcPriceData(startDate: startDate, endDate: endDate, btcPriceData: btcPriceData)
                self.initializeChart(labels: labels, values: values)
                self.updatePriceChange(startPrice: values[0], endPrice: values[values.count-1])
            }
        }  )
    }
    
    
    
    var btcPrice = "0"
    var btcPriceChange = "0"
    var btcChangeColour : UIColor = UIColor.gray
    
    @IBOutlet weak var chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        if self.selectedCountry == "india" {
            currency = "INR"
        }
        else if self.selectedCountry == "usa" {
            currency = "USD"
        }
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        rangeSegmentControlObject.selectedSegmentIndex = 1
        rangeSegmentControlObject.sendActions(for: .valueChanged)
        
        self.currentBtcPriceLabel.text = btcPrice
        self.btcPriceChangeLabel.text = btcPriceChange
        self.btcPriceChangeLabel.backgroundColor = self.btcChangeColour
        self.btcPriceChangeLabel.layer.masksToBounds = true
        self.btcPriceChangeLabel.layer.cornerRadius = 8
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // order dictionary btc data according to date
    func orderBtcPriceData(startDate: Date, endDate: Date, btcPriceData: [String:Double]) -> ([String], [Double]) {
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
        
        let lineColor = self.hexStringToUIColor(hex: "2980B9")
        line1.colors = [lineColor] //Sets the colour to blue
//        line1.colors = ChartColorTemplates.liberty()
        line1.drawCirclesEnabled = false
        line1.fillAlpha = 1
        line1.lineWidth = 1.5
        line1.mode = .cubicBezier
        
        let gradientColors = [lineColor.cgColor, UIColor.white.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        line1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        line1.drawFilledEnabled = true // Draw the Gradient
        
        let lineChartData = LineChartData() //This is the object that will be added to the chart
        
        lineChartData.addDataSet(line1) //Adds the line to the dataSet
        lineChartData.setDrawValues(false)
        
        
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
//        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.legend.enabled = false
        chart.chartDescription?.text = ""
        
        chart.data = lineChartData //finally - it adds the chart data to the chart and causes an update
        
        chart.resetZoom()
        chart.resetViewPortOffsets()
        
        chart.data?.notifyDataChanged()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            catch {
                print("Error")
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
                self.btcPriceChangeLabel.backgroundColor = self.hexStringToUIColor(hex: "#2ecc71")
            }
            else if roundedPercentage < 0 {
                self.btcPriceChangeLabel.text = "\(roundedPercentage)%  "
                self.btcPriceChangeLabel.backgroundColor = self.hexStringToUIColor(hex: "#e74c3c")
            }
            else if roundedPercentage == 0 {
                self.btcPriceChangeLabel.text = "\(roundedPercentage)%  "
                self.btcPriceChangeLabel.backgroundColor = self.hexStringToUIColor(hex: "#e74c3c")
            }
        }
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }


}
