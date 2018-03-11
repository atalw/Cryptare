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
    
    var coin: String!
    // tradingPairs: [(coin, currency)]
    var tradingPairs: [(String, String)] = []
    // markets: [currency: [(marketName, dbTableTitle)]
    var allMarkets: [String: [String: String]] = [:]
    var currentTradingPairMarkets: [String: String] = [:]
    var databaseRef: DatabaseReference!
    
    var currentTradingPair: (String, String)!
    var currentExchange: (String, String)!
    
    @IBOutlet weak var tradingPairCell: UITableViewCell!
    @IBOutlet weak var currentTradingPairLabel: UILabel!
    @IBOutlet weak var currentExchangeLabel: UILabel!
    
    @IBOutlet weak var timeTextField: UITextField!
    let timePicker = UIDatePicker()
    @IBOutlet weak var dateTextField: UITextField!
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var costPerCoinTextField: UITextField! {
        didSet {
            costPerCoinTextField.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var amountOfCoinsTextField: UITextField! {
        didSet {
            amountOfCoinsTextField.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var feesTextField: UITextField!{
        didSet {
            feesTextField.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var deductFromHoldingsLabel: UILabel!
    @IBOutlet weak var deductFromHoldingsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        timeFormatter.dateFormat  = "hh:mm a"
        dateFormatter.dateFormat = "dd MMM, YYYY"
        
        timeTextField.text = timeFormatter.string(from: Date())
        dateTextField.text = dateFormatter.string(from: Date())
        
        parentController.time = timePicker.date
        parentController.date = datePicker.date
        
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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        parentController.date = datePicker.date
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
        self.timeTextField.text = timeFormatter.string(from: timePicker.date)
        self.view.endEditing(true)
        parentController.time = timePicker.date
    }

    @IBAction func deductSwitchTapped(_ sender: Any) {
        if deductFromHoldingsSwitch.isOn {
            parentController.deductFromHoldings = true
        }
        else {
            parentController.deductFromHoldings = false
        }
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called\(textField.text!)")
        
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
        print("TextField should begin editing method called")
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("TextField should end editing method called")
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    
}
