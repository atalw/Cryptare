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
        }
    }

}


class AddPortfolioTableViewController: UITableViewController {
    
    var parentController: AddPortfolioViewController!
    
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
            if text != "" || text != nil {
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
        return true;
    }
}
