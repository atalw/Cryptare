//
//  AddPortfolioViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 27/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SwiftReorder
import FirebaseAuth
import FirebaseDatabase

class AddPortfolioViewController: UIViewController {
  
  var parentController: MainPortfolioViewController!
  //    var portfolioNames: [String]!
  
  var portfolioName: String?
  
  @IBOutlet weak var doneButton: UIBarButtonItem!
  
  @IBOutlet weak var unlockPortfolioView: UIView!
  
  @IBOutlet weak var availablePortfoliosContainerHeightConstraint: NSLayoutConstraint!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    
    
    doneButton.isEnabled = false
    
    let multiplePortfoliosPurchased = Defaults[.multiplePortfoliosPurchased]
    
    #if DEBUG
    unlockPortfolioView.isHidden = true
    #else
    if multiplePortfoliosPurchased {
      unlockPortfolioView.isHidden = true
    } else {
      unlockPortfolioView.isHidden = false
    }
    #endif
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
      Defaults[.portfolioNames].append(portfolioName!)
      
      // update on firebase
      var uid: String!
      if Auth.auth().currentUser?.uid == nil {
        print("user not signed in ERRRORRRR")
      }
      else {
        uid = Auth.auth().currentUser?.uid
        let portfolioRef = Database.database().reference().child("portfolios").child(uid).child("Names")
        portfolioRef.setValue(Defaults[.portfolioNames]) { (err, ref) in
          if err != nil {
            print(err, "Names update")
          }
        }
      }
      
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
      //            addPortfolioTableVC.portfolioNames = self.portfolioNames
    }
    else if let availablePortfolioTableVC = destinationVC as? AvailablePortfolioTableViewController {
      availablePortfolioTableVC.parentController = self
      //            availablePortfolioTableVC.portfolioNames = self.portfolioNames
    }
  }
  
}


class AddPortfolioTableViewController: UITableViewController {
  
  var parentController: AddPortfolioViewController!
  var portfolioNames: [String]!
  
  @IBOutlet weak var portfolioNameCell: UITableViewCell!
  @IBOutlet weak var portfolioNameTextField: UITextField! {
    didSet {
      portfolioNameTextField.theme_textColor = GlobalPicker.viewTextColor
      portfolioNameTextField.addDoneCancelToolbar()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    self.portfolioNameCell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    
    portfolioNames = Defaults[.portfolioNames]
    portfolioNameTextField.delegate = self
  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
  
}

extension AddPortfolioTableViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    print("TextField did begin editing method called")
  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    print("TextField did end editing method called\(textField.text!)")
    
    guard let name = textField.text else { return }
    
    if name != "" && !portfolioNames.contains(name) {
      parentController.portfolioName = name
      parentController.updateDoneButton(status: true)
    }
    else {
      parentController.portfolioName = nil
      parentController.updateDoneButton(status: false)
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
    
    self.tableView.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
    self.tableView.theme_separatorColor = GlobalPicker.tableSeparatorColor
    
    portfolioNames = Defaults[.portfolioNames]
    
    tableView.reorder.delegate = self
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    parentController.availablePortfoliosContainerHeightConstraint.constant = tableView.contentSize.height
  }
  
  func updatePortfolioName(name: String, index: Int) {
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
    
    Defaults[.portfolioNames][index] = name
    
    self.parentController.reloadPortfolios()
  }
  
  func deletePortfolio(index: Int) {
    
    Defaults[.cryptoPortfolioData].removeValue(forKey: portfolioNames[index])
    Defaults[.fiatPortfolioData].removeValue(forKey: portfolioNames[index])
    
    portfolioNames.remove(at: index)
    Defaults[.portfolioNames].remove(at: index)
    
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
    if let spacer = tableView.reorder.spacerCell(for: indexPath) {
      return spacer
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AvailablePortfolioTableViewCell
    cell!.portfolioNameTextField?.text = portfolioNames[indexPath.row]
    cell!.portfolioNameTextField.delegate = self
    
    cell!.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    cell!.portfolioNameTextField.theme_textColor = GlobalPicker.viewTextColor
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
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as? UITableViewHeaderFooterView
    
    header?.textLabel?.theme_textColor = GlobalPicker.viewAltTextColor
  }
}

class AvailablePortfolioTableViewCell: UITableViewCell {
  
  @IBOutlet weak var portfolioNameTextField: UITextField! {
    didSet {
      portfolioNameTextField.theme_textColor = GlobalPicker.viewTextColor
      portfolioNameTextField.addDoneCancelToolbar()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.theme_backgroundColor = GlobalPicker.viewBackgroundColor
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
    
    guard let name = textField.text else { return }
    
    if name != "" && !portfolioNames.contains(name) {
      
      if let indexPath = (textField.superview?.superview?.superview as! UITableView).indexPath(for: textField.superview?.superview as! AvailablePortfolioTableViewCell) {
        updatePortfolioName(name: name, index: indexPath.row)
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

extension AvailablePortfolioTableViewController: TableViewReorderDelegate {
  func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // Update data model
    let destinationName = portfolioNames[destinationIndexPath.row]
    portfolioNames[destinationIndexPath.row] = portfolioNames[sourceIndexPath.row]
    portfolioNames[sourceIndexPath.row] = destinationName
    
    Defaults[.portfolioNames] = portfolioNames
    
    // update on firebase
    var uid: String!
    if Auth.auth().currentUser?.uid == nil {
      print("user not signed in ERRRORRRR")
    }
    else {
      uid = Auth.auth().currentUser?.uid
      let portfolioRef = Database.database().reference().child("portfolios").child(uid).child("Names")
      portfolioRef.setValue(Defaults[.portfolioNames]) { (err, ref) in
        if err != nil {
          print(err, "Names update")
        }
      }
    }
    self.parentController.reloadPortfolios()
  }
}
