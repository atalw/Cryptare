//
//  AddFiatTransactionTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 09/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import Firebase

class AddFiatTransactionTableViewController: UITableViewController {
    
    var parentController: AddFiatTransactionViewController!
    
    var currency: String!
   
    let dateAndTimeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let calendar = Calendar.current
    
    var markets: [String: String]!
    var databaseRef: DatabaseReference!
    
    var currentExchange: (String, String)!

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
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    @IBOutlet weak var amountTextField: UITextField! {
        didSet {
            amountTextField.theme_textColor = GlobalPicker.viewTextColor

            amountTextField.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var feesTextField: UITextField! {
        didSet {
            feesTextField.theme_textColor = GlobalPicker.viewTextColor
            feesTextField.addDoneCancelToolbar()
        }
    }
    
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
    @IBOutlet weak var amountDescLabel: UILabel! {
        didSet {
            amountDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    @IBOutlet weak var feesDescLabel: UILabel! {
        didSet {
            feesDescLabel.theme_textColor = GlobalPicker.viewAltTextColor
        }
    }
    
    let timePicker = UIDatePicker()
    let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
        self.tableView.theme_tintColor = GlobalPicker.tableSeparatorColor

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        dateAndTimeFormatter.dateFormat = "dd MMM, YYYY hh:mm a"
        dateFormatter.dateFormat = "dd MMM, YYYY"
        timeFormatter.dateFormat = "hh:mm a"
        dateAndTimeFormatter.timeZone = TimeZone.current
        dateFormatter.timeZone = TimeZone.current
        timeFormatter.timeZone = TimeZone.current
        
        let currentDate = Date()
        
        timeTextField.text = timeFormatter.string(from: currentDate)
        dateTextField.text = dateFormatter.string(from: currentDate)
        
        parentController.date = currentDate
        
        timeTextField.delegate = self
        dateTextField.delegate = self
        feesTextField.delegate = self
        amountTextField.delegate = self
        
        createDatePicker()
        createTimePicker()
        
        databaseRef = Database.database().reference().child("BTC")

        databaseRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                for (title, data) in dict {
                    if title != "name" && title != "rank" {
                        
                        if title == self.currency {
                            self.markets = [:]
                            if let markets = data["markets"] as? [String: String] {
                                self.markets = markets
                                self.markets["None"] = "none"
                                break
                            }
                        }
                    }
                }
                self.updateLabels()
            }
        })
        
    }

    func updateLabels() {
        self.currentExchange = ("None", "none")
        self.currentExchangeLabel.text = currentExchange.0
        self.parentController.currentExchange = currentExchange
    }
    
    func updateCurrentExchange(exchange: (String, String)) {
        self.currentExchange = exchange
        self.currentExchangeLabel.text = exchange.0
        
        self.parentController.currentExchange = currentExchange
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

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
        
        if let destinationVc = segue.destination as? AvailableExchangesTableViewController {
            destinationVc.fiatParentController = self
            destinationVc.markets = self.markets
        }
    }

}

extension AddFiatTransactionTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.amountTextField {
            if let text = textField.text {
                if let amount = Double(text) {
                    parentController.amount = amount
                }
                else {
                    parentController.amount = nil
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

