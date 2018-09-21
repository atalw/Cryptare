//
//  PortfolioPieChartController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/09/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import Charts

class PortfolioPieChartController: UIViewController, ChartViewDelegate {
  
  var coins: [String] = []
  var currencies: [String] = []
  var summary: [String: [String: Double] ] = [:]
  
  var currentPortfolioValue: Double = 0
  
  @IBOutlet weak var pieChartView: PieChartView! {
    didSet {
      pieChartView.delegate = self
      
      let l = pieChartView.legend
      l.horizontalAlignment = .right
      l.verticalAlignment = .top
      l.orientation = .vertical
      l.xEntrySpace = 7
      l.yEntrySpace = 0
      l.yOffset = 0
      
      // entry label styling
      pieChartView.entryLabelColor = .white
      pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
      
      pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
      
      updateChartData(portfolioValue: currentPortfolioValue)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateChartData(portfolioValue: self.currentPortfolioValue)
  }
  
  func updateChartData(portfolioValue: Double) {
    //    if self.shouldHideData {
    //      chartView.data = nil
    //      return
    //    }
    
    //    self.setDataCount(Int(coins.count+currencies.count), range: UInt32(coins.count+currencies.count))
    
    var combinedCoinsAndCurrencies: [String] = []
    for coin in coins {
      combinedCoinsAndCurrencies.append(coin)
    }
    
    for currency in currencies {
      combinedCoinsAndCurrencies.append(currency)
    }
    
    self.setDataCount(Int(combinedCoinsAndCurrencies.count), range: UInt32(combinedCoinsAndCurrencies.count), labels: combinedCoinsAndCurrencies, portfolioValue: portfolioValue)
  }
  
  func setDataCount(_ count: Int, range: UInt32, labels: [String], portfolioValue: Double) {
    let entries = (0..<count).map { (i) -> PieChartDataEntry in
      // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
      let label = labels[i % labels.count]
      
      var value: Double = 0
      if let totalCost = summary[label]!["totalCost"] as? Double {
        value =  totalCost / portfolioValue * 100
      }
      else if let totalCost = summary[label]!["amount"] as? Double {
        value =  totalCost / portfolioValue * 100
      }
      
      print(label, value, Double(arc4random_uniform(range) + range / 5))
      return PieChartDataEntry(value: value,
                               label: label,
                               icon: #imageLiteral(resourceName: "gbp"))
    }
    
    let set = PieChartDataSet(values: entries, label: "Holdings")
    set.drawIconsEnabled = false
    set.sliceSpace = 2
    
    
    //    set.colors = ChartColorTemplates.vordiplom()
    //      + ChartColorTemplates.joyful()
    //      + ChartColorTemplates.colorful()
    //      + ChartColorTemplates.liberty()
    //      + ChartColorTemplates.pastel()
    //      + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
    
    set.colors = ChartColorTemplates.pastel()
    
    let data = PieChartData(dataSet: set)
    
    let pFormatter = NumberFormatter()
    pFormatter.numberStyle = .percent
    pFormatter.maximumFractionDigits = 1
    pFormatter.multiplier = 1
    pFormatter.percentSymbol = " %"
    data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    
    data.setValueFont(.systemFont(ofSize: 11, weight: .light))
    data.setValueTextColor(.white)
    
    pieChartView.data = data
    pieChartView.highlightValues(nil)
  }
  
  
  
}
