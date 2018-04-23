//
//  AddPairAlertViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AddPairAlertViewController: UIViewController {
  
  var tradingPair: (String, String)?
  var exchange: (String, String)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor

  }
  
  
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVc = segue.destination
    if let addAlertTableVc = destinationVc as? AddPairAlertTableViewController {
      
      if tradingPair == nil {
        tradingPair = ("None", "none")
      }
      
      if exchange == nil {
        exchange = ("None", "none")
      }
      
      addAlertTableVc.tradingPair = self.tradingPair
      addAlertTableVc.exchange = self.exchange
    }
   }
  
  
}

class AddPairAlertTableViewController: UITableViewController {
  
  
  var tradingPair: (String, String)!
  var exchange: (String, String)!
  
  @IBOutlet weak var tradingPairLabel: UILabel! {
    didSet {
      tradingPairLabel.adjustsFontSizeToFitWidth = true
      tradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
      tradingPairLabel.text = "\(tradingPair.0)/\(tradingPair.1)"
    }
  }
  @IBOutlet weak var exchangeLabel: UILabel! {
    didSet {
      exchangeLabel.adjustsFontSizeToFitWidth = true
      exchangeLabel.theme_textColor = GlobalPicker.viewTextColor
      exchangeLabel.text = "\(exchange.0)"
    }
  }
  @IBOutlet weak var thresholdPriceLabel: UITextField! {
    didSet {
      thresholdPriceLabel.adjustsFontSizeToFitWidth = true
      thresholdPriceLabel.theme_textColor = GlobalPicker.viewTextColor
      
    }
  }
  @IBOutlet weak var isAboveSwitch: UISwitch! {
    didSet {
      isAboveSwitch.setOn(true, animated: true)
    }
  }
  
  @IBOutlet weak var tradingPairDescLabel: UILabel! {
    didSet {
      tradingPairDescLabel.adjustsFontSizeToFitWidth = true
      tradingPairDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var exchangeDescLabel: UILabel! {
    didSet {
      exchangeDescLabel.adjustsFontSizeToFitWidth = true
      exchangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var thresholdPriceDescLabel: UILabel! {
    didSet {
      thresholdPriceDescLabel.adjustsFontSizeToFitWidth = true
      thresholdPriceDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  @IBOutlet weak var aboveDescLabel: UILabel! {
    didSet {
      aboveDescLabel.adjustsFontSizeToFitWidth = true
      aboveDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    tableView.tableHeaderView?.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    cell.selectionStyle = .none
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
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
