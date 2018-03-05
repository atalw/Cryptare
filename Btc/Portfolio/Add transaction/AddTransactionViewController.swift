//
//  AddTransactionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    let greenColour = UIColor.init(hex: "2ECC71")
    let redColour = UIColor.init(hex: "E74C3C")
    let navyBlueColour = UIColor.init(hex: "46637F")
    
    var transactionType: String!

    var coin: String!
    
    var currentTradingPair: (String, String)!
    var currentExchange: (String, String)!
    var costPerCoin: Double!
    var amountOfCoins: Double!
    var fees: Double!
    var time: Date!
    var date: Date!
    var deductFromHoldings: Bool!

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addTransactionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTransactionButton.setBackgroundColor(UIColor.darkGray, forState: .disabled)
        
        addTransactionButton.setTitleColor(UIColor.white, for: .normal)
        addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        addTransactionButton.isEnabled = false
        
        if transactionType == "buy" {
            addTransactionButton.setTitle("Add Buy Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(greenColour, forState: .normal)

        }
        else if transactionType == "sell" {
            addTransactionButton.setTitle("Add Sell Transaction", for: .normal)
            addTransactionButton.setBackgroundColor(redColour, forState: .normal)

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateAddTransactionButtonStatus() {
        if currentTradingPair != nil && currentExchange != nil &&
            costPerCoin != nil && amountOfCoins != nil &&
            fees != nil && time != nil && date != nil {
            addTransactionButton.isEnabled = true
        }
        else {
            addTransactionButton.isEnabled = false
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: Any) {
        
            let data: [String : Any] = ["type": transactionType,
                                        "tradingPair": currentTradingPair.1,
                                        "exchange": currentExchange.0,
                                        "costPerCoin": costPerCoin,
                                        "amountOfCoins": amountOfCoins,
                                        "fees": fees,
                                        "date": date,
                                        "time": time
                    ]
        
        NotificationCenter.default.post(name: .transactionAdded, object: nil, userInfo: data)
        
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let addTransactionController = destinationVC as? AddTransactionTableViewController {
            addTransactionController.parentController = self
            addTransactionController.transactionType = self.transactionType
            addTransactionController.coin = self.coin
        }
    }
}
