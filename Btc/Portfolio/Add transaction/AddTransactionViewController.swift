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

    var coin: String!
    
    var currentTradingPair: (String, String)!
    var currentExchange: (String, String)!
    var costPerCoin: Double!
    var amountOfCoins: Double!
    var fees: Double!
    var time: Date!
    var date: Date!
    var deductFromHoldings: Bool!

    @IBOutlet weak var buyTransactionType: UIButton!
    @IBOutlet weak var sellTransactionType: UIButton!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addTransactionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buyTransactionType.setBackgroundColor(UIColor.clear, forState: .normal)
        buyTransactionType.setTitleColor(UIColor.black, for: .normal)
        
        buyTransactionType.setBackgroundColor(greenColour, forState: .selected)
        buyTransactionType.setTitleColor(UIColor.white, for: .selected)
        
        buyTransactionType.setBackgroundColor(greenColour, forState: .highlighted)
        buyTransactionType.setTitleColor(UIColor.white, for: .highlighted)
        
        sellTransactionType.setBackgroundColor(UIColor.clear, forState: .normal)
        sellTransactionType.setTitleColor(UIColor.black, for: .normal)
        
        sellTransactionType.setBackgroundColor(redColour, forState: .selected)
        sellTransactionType.setTitleColor(UIColor.white, for: .selected)
        
        sellTransactionType.setBackgroundColor(redColour, forState: .highlighted)
        sellTransactionType.setTitleColor(UIColor.white, for: .highlighted)
        
        buyTransactionType.layer.cornerRadius = 5
        sellTransactionType.layer.cornerRadius = 5
        
        sellTransactionType.layer.borderWidth = 2
        sellTransactionType.layer.borderColor = redColour.cgColor
        
        buyTransactionType.layer.borderWidth = 2
        buyTransactionType.layer.borderColor = greenColour.cgColor
        
        buyTransactionButtonTapped(self)
        
        addTransactionButton.setBackgroundColor(navyBlueColour, forState: .normal)
        addTransactionButton.setBackgroundColor(UIColor.darkGray, forState: .disabled)
        
        addTransactionButton.setTitleColor(UIColor.white, for: .normal)
        addTransactionButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        addTransactionButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buyTransactionButtonTapped(_ sender: Any) {
        if !buyTransactionType.isSelected {
            buyTransactionType.isSelected = true
            sellTransactionType.isSelected = false
            
//            buyTransactionType.layer.borderWidth = 0
        }
    }
    
    @IBAction func sellTransactionButtonTapped(_ sender: Any) {
        if !sellTransactionType.isSelected {
            sellTransactionType.isSelected = true
            buyTransactionType.isSelected = false
            
//            sellTransactionType.layer.borderWidth = 0
        }
    }
    
    func updateAddTransactionButtonStatus() {
        if currentTradingPair != nil && currentExchange != nil &&
            costPerCoin != nil && amountOfCoins != nil &&
            fees != nil && time != nil && date != nil {
            addTransactionButton.isEnabled = true
        }
    }
    
    @IBAction func addTransactionButtonTapped(_ sender: Any) {
        
            let data: [String : Any] = ["type": "buy",
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
            addTransactionController.coin = self.coin
        }
    }
}
