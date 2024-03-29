//
//  AddFiatTransactionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AddFiatTransactionViewController: UIViewController {
  
  var parentController: FiatPortfolioViewController!
  
  let dateFormatter = DateFormatter()
  
  let greenColour = UIColor.init(hex: "2ECC71")
  let redColour = UIColor.init(hex: "E74C3C")
  let navyBlueColour = UIColor.init(hex: "46637F")
  
  var transactionType: String!
  
  var currency: String!
  var currentExchange: (String, String)!
  var amount: Double!
  var fees: Double!
  var date: Date!
  
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var addTransactionButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    addTransactionButton.setBackgroundColor(color: UIColor.darkGray, forState: .disabled)
    
    addTransactionButton.setTitleColor(UIColor.white, for: .normal)
    addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
    
    addTransactionButton.isEnabled = false
    addTransactionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    if transactionType == "deposit" {
      addTransactionButton.setTitle("Add Deposit Transaction", for: .normal)
      addTransactionButton.setBackgroundColor(color: greenColour, forState: .normal)
      
    }
    else if transactionType == "withdraw" {
      
      addTransactionButton.setTitle("Add Withdraw Transaction", for: .normal)
      addTransactionButton.setBackgroundColor(color: redColour, forState: .normal)
      
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseService.shared.updateScreenName(screenName: "Add Fiat Transaction", screenClass: "AddFiatTransactionViewController")
  }
  
  func updateAddTransactionButtonStatus() {
    if currentExchange != nil && amount != nil &&
      fees != nil && date != nil {
      addTransactionButton.isEnabled = true
    }
    else {
      addTransactionButton.isEnabled = false
    }
  }
  
  @IBAction func addTransactionButtonTapped(_ sender: Any) {
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    let dateString = dateFormatter.string(from: date)
    
    let data: [String: Any] = ["type": transactionType,
                               "exchange": currentExchange.0,
                               "amount": amount,
                               "fees": fees,
                               "date": dateString,
                               "time": time
    ]
    
    parentController.portfolioTableController.addPortfolioEntry(portfolioEntry: data)
    
    self.navigationController?.popViewController(animated: true)
    
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    let destinationVC = segue.destination
    if let tableViewController = destinationVC as? AddFiatTransactionTableViewController {
      tableViewController.parentController = self
      tableViewController.currency = currency
    }
  }
  
  
}
