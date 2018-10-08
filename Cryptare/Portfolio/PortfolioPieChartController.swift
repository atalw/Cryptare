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
  
  var combinedCoinsAndCurrencies: [String] = []
  
  @IBOutlet weak var pieChartView: PieChartView! {
    didSet {
      pieChartView.delegate = self
      
      let l = pieChartView.legend
      l.horizontalAlignment = .center
      l.verticalAlignment = .bottom
      l.orientation = .horizontal
      l.xEntrySpace = 7
      l.yEntrySpace = 10
      l.yOffset = 10
      
      
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
  
  @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl! {
    didSet {
      chartTypeSegmentedControl.theme_tintColor = GlobalPicker.segmentControlTintColor
    }
  }
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
    }
  }
  
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  @IBAction func typeSegmentControlValueChanged(_ sender: Any) {
    updateChartData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    
    updateChartData()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(changeAppearanceColours),
      name: NSNotification.Name(rawValue: ThemeUpdateNotification),
      object: nil
    )
    
    self.tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.tableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    tableViewHeightConstraint.constant = tableView.contentSize.height + 50
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  func updateChartData() {
    
    combinedCoinsAndCurrencies = []
    
    for coin in coins {
      combinedCoinsAndCurrencies.append(coin)
    }
    
    if self.chartTypeSegmentedControl.selectedSegmentIndex == 0 {
      for currency in currencies {
        combinedCoinsAndCurrencies.append(currency)
      }
    }
    
//    combinedCoinsAndCurrencies = combinedCoinsAndCurrencies.sorted(by: {$0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending})
    
    self.setDataCount(Int(combinedCoinsAndCurrencies.count), labels: combinedCoinsAndCurrencies)
    
    if self.tableView != nil {
      self.tableView.reloadData()
    }
  }
  
  func setDataCount(_ count: Int, labels: [String]) {
    var entries = (0..<count).map { (i) -> PieChartDataEntry in
      // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
      let label = labels[i % labels.count]
      var value: Double = 0
      
      if self.chartTypeSegmentedControl.selectedSegmentIndex == 0 {
        
        if let totalCost = summary[label]!["totalCost"] {
          value =  totalCost / currentPortfolioValue * 100
        }
        else if let totalCost = summary[label]!["amount"] {
          value =  totalCost / currentPortfolioValue * 100
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
    
    entries = entries.sorted(by: {$0.value > $1.value})

    combinedCoinsAndCurrencies = []
    for entry in entries {
      combinedCoinsAndCurrencies.append(entry.label ?? "None")
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
    
    pieChartView.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
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

extension PortfolioPieChartController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Distribution"
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return combinedCoinsAndCurrencies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChartInfoTableViewCell
    
    let row = indexPath.row
    let label = combinedCoinsAndCurrencies[row]
    
    cell.logoImage.image = UIImage(named: label.lowercased())
    
    var fullName: String = ""
    
    if let name = Defaults[.cryptoSymbolNamePairs][label] as? String {
      fullName = name
    }
    
//    for (symbol, name) in GlobalValues.coins {
//      if symbol == label {
//        fullName = name
//      }
//    }
    
    if fullName == "" {
      for (_, symbol, _, name) in GlobalValues.countryList {
        if symbol == label {
          cell.fullNameLabel.text = name
        }
      }
    }
    else {
      cell.fullNameLabel?.text = fullName
    }
    
    cell.titleLabel?.text = label
    
    if self.chartTypeSegmentedControl.selectedSegmentIndex == 0 {
      if let totalCost = summary[label]!["totalCost"] {
//        let value =  totalCost / currentPortfolioValue * 100
        cell.valueLabel?.text = totalCost.asCurrency
      }
      else if let totalCost = summary[label]!["amount"] {
//        let value =  totalCost / currentPortfolioValue * 100
        cell.valueLabel?.text = totalCost.asCurrency
      }
    }
    else {
      if let amountOfCoins = summary[label]!["amountOfCoins"] {
        let value = amountOfCoins / self.totalAmountOfCoins * 100
        cell.valueLabel?.text = "\(amountOfCoins) \(label)"
      }
    }
    
    return cell
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

