//
//  AddTransactionTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 25/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase

class AddTransactionTableViewController: UITableViewController {
    
    var parentController: AddTransactionViewController!
    var transactionType: String!
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let calendar = Calendar.current

    var coin: String!
    // tradingPairs: [(coin, currency)]
    var tradingPairs: [(String, String)] = []
    // markets: [currency: [(marketName, dbTableTitle)]
    var allMarkets: [String: [String: String]] = [:]
    var currentTradingPairMarkets: [String: String] = [:]
    var databaseRef: DatabaseReference!
    
    var currentTradingPair: (String, String)!
    var currentExchange: (String, String)!
    
    var databaseReference: DatabaseReference!
    var all_exchanges_update_type: [String: String] = [:]

    @IBOutlet weak var tradingPairCell: UITableViewCell!
    @IBOutlet weak var currentTradingPairLabel: UILabel! {
        didSet {
            currentTradingPairLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var currentExchangeLabel: UILabel! {
        didSet {
            currentExchangeLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    @IBOutlet weak var timeTextField: UITextField! {
        didSet {
            timeTextField.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    let timePicker = UIDatePicker()
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var costPerCoinTextField: UITextField! {
        didSet {
            costPerCoinTextField.theme_textColor = GlobalPicker.viewTextColor
            costPerCoinTextField.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var amountOfCoinsTextField: UITextField! {
        didSet {
            amountOfCoinsTextField.theme_textColor = GlobalPicker.viewTextColor
            amountOfCoinsTextField.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var feesTextField: UITextField!{
        didSet {
            feesTextField.theme_textColor = GlobalPicker.viewTextColor
            feesTextField.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var deductFromHoldingsLabel: UILabel! {
        didSet {
            deductFromHoldingsLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var deductFromHoldingsSwitch: UISwitch!
    
    @IBOutlet weak var exchangeDescLabel: UILabel! {
        didSet {
            exchangeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var timeDescLabel: UILabel! {
        didSet {
            timeDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var dateDescLabel: UILabel! {
        didSet {
            dateDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var costPerCoinDescLabel: UILabel! {
        didSet {
            costPerCoinDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var amountOfCoinsDescLabel: UILabel! {
        didSet {
            amountOfCoinsDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var feesDescLabel: UILabel! {
        didSet {
                feesDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    @IBOutlet weak var tradingPairDescLabel: UILabel! {
        didSet {
            tradingPairDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        timeFormatter.dateFormat  = "hh:mm a"
        dateFormatter.dateFormat = "dd MMM, YYYY"
        
        dateFormatter.timeZone = TimeZone.current
        timeFormatter.timeZone = TimeZone.current
        
        let currentDate = Date()
        
        timeTextField.text = timeFormatter.string(from: currentDate)
        dateTextField.text = dateFormatter.string(from: currentDate)
        
        parentController.date = currentDate
        
        createDatePicker()
        createTimePicker()
        
        costPerCoinTextField.delegate = self
        amountOfCoinsTextField.delegate = self
        feesTextField.delegate = self
        
        databaseRef = Database.database().reference().child(coin)
        
        databaseRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                for (title, data) in dict {
                    if title != "name" && title != "rank" {
                        self.tradingPairs.append((self.coin, title))
                        self.allMarkets[title] = [:]
                        if let markets = data["markets"] as? [String: String] {
//                            print(markets)
                            self.allMarkets[title] = markets
                        }
                        self.allMarkets[title]!["None"] = "none"
                    }
                }
                self.updateLabels()
            }
        })
        
        deductFromHoldingsSwitch.isOn = true
        parentController.deductFromHoldings = true
        
    }
    
    func updateLabels() {
        for (coin, currency) in tradingPairs {
            if GlobalValues.currency == currency {
                self.currentTradingPair = (coin, currency)
                self.currentTradingPairLabel.text = "\(coin)-\(currency)"
                
                if transactionType == "buy" {
                    self.deductFromHoldingsLabel.text = "Deduct from \(currency) holdings"

                }
                else if transactionType == "sell" {
                    self.deductFromHoldingsLabel.text = "Add to \(currency) holdings"
                }
                
                if let markets = allMarkets[currency] as? [String: String] {
                    self.currentTradingPairMarkets = markets
                    self.currentExchange = ("None", "none")
                    self.currentExchangeLabel.text = currentExchange.0
                }
                
                self.parentController.currentTradingPair = self.currentTradingPair
                self.parentController.currentExchange = currentExchange
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parentController.tableViewHeightConstraint.constant = tableView.contentSize.height
        databaseReference = Database.database().reference()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseReference.removeAllObservers()
    }
    
    func updateCurrentTradingPair(pair: (String, String)) {
        self.currentTradingPair = pair
        self.currentTradingPairLabel.text = "\(pair.0)-\(pair.1)"
        
        
        if transactionType == "buy" {
            self.deductFromHoldingsLabel.text = "Deduct from \(pair.1) holdings"

        }
        else if transactionType == "sell" {
            self.deductFromHoldingsLabel.text = "Add to \(pair.1) holdings"

        }
        
        if let markets = allMarkets[pair.1] as? [String: String] {
            currentTradingPairMarkets = markets
            self.currentExchange = ("None", "none")
            self.currentExchangeLabel.text = currentExchange.0
        }
        
        self.parentController.currentTradingPair = self.currentTradingPair
        self.parentController.currentExchange = currentExchange
    }
    
    func updateCurrentExchange(exchange: (String, String)) {
        self.currentExchange = exchange
        self.currentExchangeLabel.text = exchange.0
        
        self.parentController.currentExchange = currentExchange
        
        if exchange.0 != "None" {
            updateCostPerCoinTextfield(exchange: exchange)
        }
        else {
            self.costPerCoinTextField.text = ""
        }
    }
    
    func updateCostPerCoinTextfield(exchange: (String, String)) {
        self.databaseReference.child("all_exchanges_update_type").observe(.value, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: String] {
                self.all_exchanges_update_type = dict
                let exchangeName = exchange.0
                if self.all_exchanges_update_type[exchangeName] == "update" {
                    self.databaseReference.child(exchange.1).observe(.value, with: {(snapshot) -> Void in
                        if let dict = snapshot.value as? [String: AnyObject] {
                            //                            self.updateFirebaseObservedData(dict: dict, title: fiatExchangeRef.1)
                            let buyPrice = dict["buy_price"] as! Double
                            let sellPrice = dict["sell_price"] as! Double
                            
                            if self.transactionType == "buy" {
                                self.costPerCoinTextField.text = "\(buyPrice)"
                                self.parentController.costPerCoin = buyPrice
                            }
                            else {
                                self.costPerCoinTextField.text = "\(sellPrice)"
                                self.parentController.costPerCoin = sellPrice
                            }
                        }
                    })
                }
                else {
                    self.databaseReference.child(exchange.1).queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                        if let dict = snapshot.value as? [String: AnyObject] {
                            let buyPrice = dict["buy_price"] as! Double
                            let sellPrice = dict["sell_price"] as! Double
                            
                            if self.transactionType == "buy" {
                                self.costPerCoinTextField.text = "\(buyPrice)"
                                self.parentController.costPerCoin = buyPrice
                            }
                            else {
                                self.costPerCoinTextField.text = "\(sellPrice)"
                                self.parentController.costPerCoin = sellPrice
                            }
                        }
                    })
                }
            }
        })
        
    }
    
    func createDatePicker() {
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = dateFormatter.date(from: "01 Jan, 2010")
        datePicker.maximumDate = Date()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedDate))
        toolbar.setItems([doneBarButton], animated: false)
        
        self.dateTextField.inputAccessoryView = toolbar
        self.dateTextField.inputView = datePicker
    }
    
    @objc func donePressedDate() {
        self.dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: parentController.date)
        
        components.year = calendar.component(.year, from: datePicker.date)
        components.month = calendar.component(.month, from: datePicker.date)
        components.day = calendar.component(.day, from: datePicker.date)
        
        parentController.date = calendar.date(from: components)
    }
    
    func createTimePicker() {
        timePicker.datePickerMode = .time
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedTime))
        toolbar.setItems([doneBarButton], animated: false)
        
        self.timeTextField.inputAccessoryView = toolbar
        self.timeTextField.inputView = timePicker
    }
    
    @objc func donePressedTime() {
        let time = timePicker.date
        self.view.endEditing(true)
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: parentController.date)
        
        components.hour = calendar.component(.hour, from: time)
        components.minute = calendar.component(.minute, from: time)
        components.second = calendar.component(.second, from: time)
        
        timeTextField.text = timeFormatter.string(from: time)
        
        parentController.date = calendar.date(from: components)
    }

    @IBAction func deductSwitchTapped(_ sender: Any) {
        if deductFromHoldingsSwitch.isOn {
            parentController.deductFromHoldings = true
        }
        else {
            parentController.deductFromHoldings = false
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        
        header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? TradingPairTableViewController {
            destinationVC.parentController = self
            destinationVC.tradingPairs = self.tradingPairs
        }
        else if let destinationVc = segue.destination as? AvailableExchangesTableViewController {
            destinationVc.cryptoParentController = self
            destinationVc.markets = self.currentTradingPairMarkets
        }
        
    }

}

extension AddTransactionTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.costPerCoinTextField {
            if let text = textField.text {
                if let costPerCoin = Double(text) {
                    parentController.costPerCoin = costPerCoin
                }
                else {
                    parentController.costPerCoin = nil
                }
            }
        }
        else if textField == self.amountOfCoinsTextField {
            if let text = textField.text {
                if let amountOfCoins = Double(text) {
                    parentController.amountOfCoins = amountOfCoins
                }
                else {
                    parentController.amountOfCoins = nil
                }
            }
        }
        else if textField == self.feesTextField {
            if let text = textField.text {
                if let fees = Double(text) {
                    parentController.fees = fees
                }
                else {
                    parentController.fees = nil
                }
            }
        }
        parentController.updateAddTransactionButtonStatus()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
