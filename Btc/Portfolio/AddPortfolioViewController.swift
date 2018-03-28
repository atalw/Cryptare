//
//  AddPortfolioViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 27/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class AddPortfolioViewController: UIViewController {
    
    var parentController: MainPortfolioViewController!
    var portfolioNames: [String]!
    
    var portfolioName: String?

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
    }

    func updateDoneButton(status: Bool) {
        doneButton.isEnabled = status
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if portfolioName != nil {
            var cryptoPortfolioData = Defaults[.cryptoPortfolioData]
            var fiatPortfolioData = Defaults[.fiatPortfolioData]
            
            cryptoPortfolioData[portfolioName!] = [:]
            fiatPortfolioData[portfolioName!] = [:]
            
            Defaults[.cryptoPortfolioData] = cryptoPortfolioData
            Defaults[.fiatPortfolioData] = fiatPortfolioData
            
            parentController.viewControllerList = parentController.getPortfolios()
            parentController.pagingViewController.reloadData()
            
            navigationController?.popViewController(animated: true)
        }

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        
        if let addPortfolioTableVC = destinationVC as? AddPortfolioTableViewController {
            addPortfolioTableVC.parentController = self
            addPortfolioTableVC.portfolioNames = self.portfolioNames
        }
        else if let availablePortfolioTableVC = destinationVC as? AvailablePortfolioTableViewController {
            availablePortfolioTableVC.parentController = self
            availablePortfolioTableVC.portfolioNames = self.portfolioNames
        }
    }

}


class AddPortfolioTableViewController: UITableViewController {
    
    var parentController: AddPortfolioViewController!
    var portfolioNames: [String]!

    @IBOutlet weak var portfolioNameTextField: UITextField! {
        didSet {
            portfolioNameTextField.addDoneCancelToolbar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        portfolioNameTextField.delegate = self
    }
}

extension AddPortfolioTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called\(textField.text!)")
        
        if let text = textField.text {
            if text != "" && text != nil && !portfolioNames.contains(text) {
                parentController.portfolioName = text
                parentController.updateDoneButton(status: true)
            }
            else {
                parentController.portfolioName = nil
                parentController.updateDoneButton(status: false)
            }
        }
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
        return true
    }
}

class AvailablePortfolioTableViewController: UITableViewController {
    
    var parentController: AddPortfolioViewController!
    var portfolioNames: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Portfolios"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolioNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AvailablePortfolioTableViewCell
        cell!.portfolioNameTextField?.text = portfolioNames[indexPath.row]
        cell!.portfolioNameTextField.delegate = self
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
//            let portfolioEntry = self.portfolioEntries[indexPath.row]
//            self.portfolioEntries.remove(at: indexPath.row)
//            self.deletePortfolioEntry(portfolioEntry: portfolioEntry)
            tableView.deleteRows(at: [indexPath], with: .fade)
//            self.parentController.setTotalPortfolioValues()
        }
        
        return [delete]
    }
}

class AvailablePortfolioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var portfolioNameTextField: UITextField! {
        didSet {
            portfolioNameTextField.addDoneCancelToolbar()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension AvailablePortfolioTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called\(textField.text!)")
        
        if let text = textField.text {
            if text != "" && text != nil {
//                parentController.portfolioName = text
//                parentController.updateDoneButton(status: true)
                print("text")
            }
            else {
//                parentController.portfolioName = nil
//                parentController.updateDoneButton(status: false)
            }
        }
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
        return true
    }
}
