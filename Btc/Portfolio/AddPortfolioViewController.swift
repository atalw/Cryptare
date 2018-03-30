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
    
    @IBOutlet weak var unlockPortfolioView: UIView!
    @IBOutlet weak var unlockPortfolioButton: UIButton!
    
    @IBOutlet weak var availablePortfoliosContainerHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        let multiplePortfoliosPurchased = Defaults[.multiplePortfoliosPurchased]
        
        if multiplePortfoliosPurchased {
            unlockPortfolioView.isHidden = true
            self.unlockPortfolioButton.titleLabel?.textAlignment = NSTextAlignment.center
        }
        else {
            unlockPortfolioView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !unlockPortfolioView.isHidden {
            IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
                if success {
                    if products != nil {
                        var price = 0.0.asCurrency
                        for product in products! {
                            if product.localizedTitle == "Multiple Portfolios" {
                                price = product.localizedPrice()
                            }
                        }
                        
                        self.unlockPortfolioButton.setTitle(" Unlock unlimited portfolios for a one-time purchase of \(price). ", for: .normal)
                            self.unlockPortfolioButton.titleLabel?.textAlignment = NSTextAlignment.center
                        self.unlockPortfolioButton.titleLabel?.lineBreakMode = .byWordWrapping
                        self.unlockPortfolioButton.addTarget(self, action: #selector(self.unlockPortfolioButtonTapped), for: .touchUpInside)
                    }
                }
            })
        }
        
    }
    
    @objc func unlockPortfolioButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.openLeft()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        
        let leftViewController = self.slideMenuController()?.leftViewController as? LeftViewController
        let indexPath = IndexPath(row: 3, section: 0)
        leftViewController?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        leftViewController?.tableView((leftViewController?.tableView)!, didSelectRowAt: indexPath)
        
        self.navigationController?.closeLeft()
    }

    func updateDoneButton(status: Bool) {
        doneButton.isEnabled = status
    }
    
    func reloadPortfolios() {
        parentController.viewControllerList = parentController.getPortfolios()
        parentController.pagingViewController.dataSource = parentController
        parentController.pagingViewController.reloadData()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if portfolioName != nil {
            var cryptoPortfolioData = Defaults[.cryptoPortfolioData]
            var fiatPortfolioData = Defaults[.fiatPortfolioData]
            
            cryptoPortfolioData[portfolioName!] = [:]
            fiatPortfolioData[portfolioName!] = [:]
            
            Defaults[.cryptoPortfolioData] = cryptoPortfolioData
            Defaults[.fiatPortfolioData] = fiatPortfolioData
            
            reloadPortfolios()
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        parentController.availablePortfoliosContainerHeightConstraint.constant = tableView.contentSize.height
    }
    
    func updatePortfolioName(name: String, index: Int) {
        print(name, index)
        
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to change the portfolio name from \(portfolioNames[index]) to \(name)?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
            print("yes tapped")
            self.changePortfolioName(name: name, index: index)
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: { actino -> Void in
            print("no tapped")
        })
        
        dialogMessage.addAction(yesAction)
        dialogMessage.addAction(cancelAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func changePortfolioName(name: String, index: Int) {
        let oldPortfolioName = portfolioNames[index]
        
        let cryptoData = Defaults[.cryptoPortfolioData][oldPortfolioName]
        Defaults[.cryptoPortfolioData][name] = cryptoData
        Defaults[.cryptoPortfolioData].removeValue(forKey: oldPortfolioName)
        
        let fiatData = Defaults[.fiatPortfolioData][oldPortfolioName]
        Defaults[.fiatPortfolioData][name] = fiatData
        Defaults[.fiatPortfolioData].removeValue(forKey: oldPortfolioName)
        
        self.parentController.reloadPortfolios()
    }
    
    func deletePortfolio(index: Int) {
        
        Defaults[.cryptoPortfolioData].removeValue(forKey: portfolioNames[index])
        Defaults[.fiatPortfolioData].removeValue(forKey: portfolioNames[index])
        
        portfolioNames.remove(at: index)
        
        parentController.reloadPortfolios()
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
            
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this portfolio? All transactions will be deleted.", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
                print("yes tapped")
                self.deletePortfolio(index: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            
            let cancelAction = UIAlertAction(title: "No", style: .default, handler: { actino -> Void in
                print("no tapped")
            })
            
            dialogMessage.addAction(yesAction)
            dialogMessage.addAction(cancelAction)
            
            self.present(dialogMessage, animated: true, completion: nil)
            
        }
        
        return [delete]
    }
    var index: Int!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.index = indexPath.row
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
            if text != "" && text != nil && !portfolioNames.contains(text) {
//                parentController.portfolioName = text
//                parentController.updateDoneButton(status: true)
                print("text")
                
                if let indexPath = (textField.superview?.superview?.superview as! UITableView).indexPath(for: textField.superview?.superview as! AvailablePortfolioTableViewCell) {
                    updatePortfolioName(name: text, index: indexPath.row)
                }
                
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
