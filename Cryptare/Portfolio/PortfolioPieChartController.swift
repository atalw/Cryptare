//
//  PortfolioPieChartController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 21/09/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import Charts
import SwiftTheme
import SwiftyUserDefaults

class PortfolioPieChartController: UIViewController, ChartViewDelegate {
  
  var coins: [String] = []
  var currencies: [String] = []
  var summary: [String: [String: Double] ] = [:]
  
  var currentPortfolioValue: Double = 0.0
  var totalAmountOfCoins: Double = 0.0
  
  @IBOutlet weak var pieChartView: PieChartView! {
    didSet {
      pieChartView.delegate = self
      
      let l = pieChartView.legend
      l.horizontalAlignment = .center
      l.verticalAlignment = .bottom
      l.orientation = .horizontal
      l.xEntrySpace = 7
      l.yEntrySpace = 0
      l.yOffset = 0
      
      let selectedIndex = Defaults[.currentThemeIndex]
      if selectedIndex == 0 {
        pieChartView.legend.textColor = UIColor.black
      }
      else if selectedIndex == 1 {
        pieChartView.legend.textColor = UIColor.white
      }
      
      // entry label styling
      pieChartView.entryLabelColor = .white
      pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .regular)
      
      pieChartView.animate(xAxisDuration: 0.9, easingOption: .easeOutBack)
      
      updateChartData()
    }
  }
  
  @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!
  
  @IBAction func typeSegmentControlValueChanged(_ sender: Any) {
    updateChartData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    
    updateChartData()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(changeAppearanceColours),
      name: NSNotification.Name(rawValue: ThemeUpdateNotification),
      object: nil
    )
  }
  
  func updateChartData() {
    
    var combinedCoinsAndCurrencies: [String] = []
    for coin in coins {
      combinedCoinsAndCurrencies.append(coin)
    }
    
    if self.chartTypeSegmentedControl.selectedSegmentIndex == 0 {
      for currency in currencies {
        combinedCoinsAndCurrencies.append(currency)
      }
    }
    
    self.setDataCount(Int(combinedCoinsAndCurrencies.count), labels: combinedCoinsAndCurrencies, portfolioValue: currentPortfolioValue)
  }
  
  func setDataCount(_ count: Int, labels: [String], portfolioValue: Double) {
    let entries = (0..<count).map { (i) -> PieChartDataEntry in
      // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
      let label = labels[i % labels.count]
      var value: Double = 0
      
      if self.chartTypeSegmentedControl.selectedSegmentIndex == 0 {
        
        if let totalCost = summary[label]!["totalCost"] {
          value =  totalCost / portfolioValue * 100
        }
        else if let totalCost = summary[label]!["amount"] {
          value =  totalCost / portfolioValue * 100
        }
        
      }
      else {
        if let amountOfCoins = summary[label]!["amountOfCoins"] {
          value = amountOfCoins / totalAmountOfCoins * 100
        }
      }
      return PieChartDataEntry(value: value,
                               label: label,
                               icon: #imageLiteral(resourceName: "gbp"))
    }
    
    let set = PieChartDataSet(values: entries, label: "")
    set.drawIconsEnabled = false
    set.sliceSpace = 0
    
    //    set.colors = ChartColorTemplates.vordiplom()
    //      + ChartColorTemplates.joyful()
    //      + ChartColorTemplates.colorful()
    //      + ChartColorTemplates.liberty()
    //      + ChartColorTemplates.pastel()
    //      + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
    
    set.colors = ChartColorTemplates.material() + ChartColorTemplates.colorful()
    
    let data = PieChartData(dataSet: set)
    
    let pFormatter = NumberFormatter()

    pFormatter.numberStyle = .percent
    pFormatter.maximumFractionDigits = 2
    pFormatter.multiplier = 1
    pFormatter.percentSymbol = " %"
    data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    
//    if chartTypeSegmentedControl.selectedSegmentIndex == 0 {
//      UserDefaults.standard.set(self.currentPortfolioValue, forKey: "totalValue")
//    }
//    else if chartTypeSegmentedControl.selectedSegmentIndex == 1 {
//      UserDefaults.standard.set(self.totalAmountOfCoins, forKey: "totalValue")
//    }
//    let formatter:ChartFormatter = ChartFormatter()
//    data.setValueFormatter(formatter)
    
    data.setValueFont(.systemFont(ofSize: 11, weight: .regular))
    data.setValueTextColor(.white)
    
    
    pieChartView.data = data
    pieChartView.highlightValues(nil)
    pieChartView.drawHoleEnabled = false
    pieChartView.holeColor = UIColor.clear
//    pieChartView.holeRadiusPercent = 20
    pieChartView.transparentCircleRadiusPercent = 0
    
    pieChartView.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    
    pieChartView.chartDescription?.text = ""
    
//    pieChartView.tex
    
    pieChartView.drawSliceTextMinimumAngle = 20
    
  }
  
  @objc func changeAppearanceColours() {
    let themeIndex = ThemeManager.currentThemeIndex
    if themeIndex == 0 {
      pieChartView.legend.textColor = UIColor.black
    }
    else if themeIndex == 1 {
      pieChartView.legend.textColor = UIColor.white
    }
  }
  
}

public class ChartFormatter: NSObject, IValueFormatter{
  
  public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
    
    
    let valueToUse = Double(round(10*value)/10)
    print("valueToUse: \(valueToUse)")
    let minNumber = 5.0
    
    if(valueToUse<minNumber) {
      
      return ""
    }
    else {
      return String(valueToUse) + "%"
    }
  }
  
}
