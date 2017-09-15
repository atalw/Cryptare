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
    
    let dateFormatter = DateFormatter()
    let todaysDate = Date()
    
    @IBAction func rangeSegmentedControl(_ sender: Any) {
        let index = (sender as? UISegmentedControl)?.selectedSegmentIndex
        
        var startDate: Date = self.todaysDate
        let endDate: Date = self.todaysDate
        let endDateString = dateFormatter.string(from: endDate)
        var url: URL!
        
        if index == 0 { // day
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=2017-09-01&end=2017-09-08")!
        }
        else if index == 1 { // week
            startDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=\(startDateString)&end=\(endDateString)")!

        }
        else if index == 2 { // month
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=\(startDateString)&end=\(endDateString)")!

        }
        else if index == 3 { // year
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: todaysDate)!
            let startDateString = dateFormatter.string(from: startDate)
            
            url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=\(startDateString)&end=\(endDateString)")!
            
        }
        
        self.getAllTimeBtcData(url: url, completion: { success, btcPriceData in
            if (success) {
                let (labels, values) = self.orderBtcPriceData(startDate: startDate, endDate: endDate, btcPriceData: btcPriceData)
                self.initializeChart(labels: labels, values: values)
            }
        }  )
    }
    
    @IBOutlet weak var currentBtcPriceLabel: UILabel!
    @IBOutlet weak var btcPriceChangeLabel: UILabel!
    
    var btcPrice = "0"
    var btcPriceChange = "0"
    var btcChangeColour : UIColor = UIColor.gray
    
    @IBOutlet weak var chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        let lastWeekDate = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: todaysDate)!
        let lastWeekDateString = dateFormatter.string(from: lastWeekDate)
        
        self.getAllTimeBtcData(url: URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=\(lastWeekDateString)&end=\(todaysDateString)")!, completion: { success, btcPriceData in
            if (success) {
                let (labels, values) = self.orderBtcPriceData(startDate: lastWeekDate, endDate: self.todaysDate, btcPriceData: btcPriceData)
                self.initializeChart(labels: labels, values: values)
            }
        }  )
        
        self.currentBtcPriceLabel.text = btcPrice
        self.btcPriceChangeLabel.text = btcPriceChange
        self.btcPriceChangeLabel.backgroundColor = self.btcChangeColour
        self.btcPriceChangeLabel.layer.masksToBounds = true
        self.btcPriceChangeLabel.layer.cornerRadius = 8
        
//        chart.delegate = self
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
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [UIColor.blue] //Sets the colour to blue
        line1.drawCirclesEnabled = false
        
        let lineChartData = LineChartData() //This is the object that will be added to the chart
        
        lineChartData.addDataSet(line1) //Adds the line to the dataSet
        lineChartData.setDrawValues(false)
        
        
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
//        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = true
        
        
        chart.data = lineChartData //finally - it adds the chart data to the chart and causes an update
        
        chart.resetZoom()
        chart.resetViewPortOffsets()
        
        chart.data?.notifyDataChanged()
//        chart.notifyDataSetChanged()
//        chart.invalidateIntrinsicContentSize()
        chart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Helper Functions
    // ################
    
    private func generateRandomData(_ numberOfItems: Int, max: Double, shouldIncludeOutliers: Bool = true) -> [Float] {
        var data = [Float]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Float(arc4random()).truncatingRemainder(dividingBy: Float(max))
            
            if(shouldIncludeOutliers) {
                if(arc4random() % 100 < 10) {
                    randomNumber *= 3
                }
            }
            
            data.append(randomNumber)
        }
        return data
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
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let prices = JSON(data: data)["bpi"].dictionary
                for (date, subJson):(String, JSON) in prices! {
                    // store data in dictionary and then sort data according to date because you should not rely on the order of JSON response
//                    print(prices![date])
//                    print(subJson.double)
                    if let price = subJson.double {
                        plotData.append(price)
                        btcPriceData[date] = price
                    }
                    
                }
                DispatchQueue.main.async {
                    completion(true, btcPriceData)
                }
//                if let inrPrice = json?["bpi"] as? [String: Double] {
//                    print(inrPrice)
//                    for (_, price) in inrPrice {
//                        plotData.append(price)
//                    }
//                    DispatchQueue.main.async {
//                        completion(true, plotData)
//                    }
//                }
                
            }
            catch {
                print("Error")
            }
        }
        task.resume()
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
