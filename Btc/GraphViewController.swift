//
//  GraphViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import ScrollableGraphView

class GraphViewController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var currentBtcPriceLabel: UILabel!
    @IBOutlet weak var btcPriceChangeLabel: UILabel!
    
    var btcPrice = "0"
    var btcPriceChange = "0"
    var btcChangeColour : UIColor = UIColor.gray
    
//    @IBOutlet var graphView: ScrollableGraphView!
    @IBOutlet weak var graphView: ScrollableGraphView!
    
    var numberOfItems = 30
    var plotOneData: [Double] = [] {didSet { setupGraph(graphView: graphView)}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getAllTimeBtcData(completion: { success in
            self.plotOneData = success
        }  )

        self.currentBtcPriceLabel.text = btcPrice
        self.btcPriceChangeLabel.text = btcPriceChange
        self.btcPriceChangeLabel.backgroundColor = self.btcChangeColour
        
        // Do any additional setup after loading the view.
        graphView.dataSource = self
        setupGraph(graphView: graphView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // ScrollableGraphViewDataSource
    // #############################
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "one":
            return plotOneData[pointIndex]
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "FEB \(pointIndex)"
    }
    
    func numberOfPoints() -> Int {
        return plotOneData.count
    }
    
    // Helper Functions
    // ################
    
    // When using Interface Builder, only add the plots and reference lines in code.
    func setupGraph(graphView: ScrollableGraphView) {
        
        // Setup the line plot.
        let linePlot = LinePlot(identifier: "one")
        
        linePlot.lineWidth = 1
        linePlot.lineColor = self.hexStringToUIColor(hex: "#ffffff")
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        linePlot.fillGradientStartColor = self.hexStringToUIColor(hex: "#ffffff")
        linePlot.fillGradientEndColor = self.hexStringToUIColor(hex: "#555555")
        
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let dotPlot = DotPlot(identifier: "darkLineDot") // Add dots as well.
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = UIColor.white
        
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.black.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.black
        
//        referenceLines.positionType = .absolute
        // Reference lines will be shown at these values on the y-axis.
//        referenceLines.absolutePositions = [10, 20, 25, 30]
//        referenceLines.includeMinMax = false
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        // Setup the graph
//        graphView.backgroundFillColor = self.hexStringToUIColor(hex: "#333333")
//        graphView.dataPointSpacing = 80
//        
//        graphView.shouldAnimateOnStartup = true
//        graphView.shouldAdaptRange = true
//        graphView.shouldRangeAlwaysStartAtZero = true
//        
//        graphView.rangeMax = 50
        
        
        graphView.shouldAdaptRange = true

        // Add everything to the graph.
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: dotPlot)
    
    }
    
    private func generateRandomData(_ numberOfItems: Int, max: Double, shouldIncludeOutliers: Bool = true) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
            
            if(shouldIncludeOutliers) {
                if(arc4random() % 100 < 10) {
                    randomNumber *= 3
                }
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    func getAllTimeBtcData(completion: @escaping (_ success: [Double]) -> ()) {
        var plotData = [Double]()
        
        let url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=INR&start=2011-01-01&end=2017-09-01")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                if let inrPrice = json?["bpi"] as? [String: Double] {
                    for (_, price) in inrPrice {
                        plotData.append(price)
                    }
                    completion(plotData)
                }
                
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
