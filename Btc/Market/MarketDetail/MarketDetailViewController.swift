//
//  MarketDetailViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 14/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Charts
import Firebase

class MarketDetailViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let numberFormatter = NumberFormatter()
    
    var market: String!
    var databaseChildTitle: String!
    var ref: DatabaseReference!
    var marketDescription: String!
    var links: [String] = []
    
    // MARK: IBOutlets\
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buyPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var marketDescriptionLabel: UILabel!
    
    @IBOutlet weak var chart: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        buyPriceLabel.adjustsFontSizeToFitWidth = true
        sellPriceLabel.adjustsFontSizeToFitWidth = true
        volumeLabel.adjustsFontSizeToFitWidth = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = market
        
        let selectedCountry = self.defaults.string(forKey: "selectedCountry")
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        if selectedCountry == "india" {
            self.numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if selectedCountry == "usa" {
            self.numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        titleLabel.text = market
        
        ref = Database.database().reference().child(databaseChildTitle)
        var labels: [String] = []
        for index in 1..<61 {
            labels.append(String(index))
        }
        
        var values: [Double] = []
        
        ref.queryLimited(toLast: 60).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: AnyObject] {
                let currentBuyPrice = dict["buy_price"] as! Double
                //                let currentSellPrice = dict["sell_price"] as! Double
                values.append(currentBuyPrice)
                self.initializeChart(labels: labels, values: values)
            }
        })
        
        ref.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: AnyObject] {
                let currentBuyPrice = dict["buy_price"] as! Double
                let currentSellPrice = dict["sell_price"] as! Double
                var currentVolume = 0.0
                if let vol = dict["vol_24hrs"] as? Double {
                    currentVolume = vol
                }
                else if let vol = dict["coin_volume_24hrs"] as? Double {
                    currentVolume = vol
                }
                
                DispatchQueue.main.async {
                    self.buyPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: currentBuyPrice))
                    self.sellPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: currentSellPrice))
                    let formattedVolume = Double(round(10000*currentVolume)/10000)
                    self.volumeLabel.text = "₿ \(formattedVolume)"
                }
            }
        })
        
        marketDescriptionLabel.text = marketDescription
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeAllObservers()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        chart.leftAxis.enabled = true
        chart.leftAxis.drawGridLinesEnabled = false
        
        chart.xAxis.enabled = true
        chart.xAxis.drawLabelsEnabled = true
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        
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


}
