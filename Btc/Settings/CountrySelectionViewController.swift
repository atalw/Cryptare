//
//  CountrySelectionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 26/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Firebase

class CountrySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableViewController : countryTableViewController!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var selectCountryTitleLabel: UILabel! {
        didSet {
            selectCountryTitleLabel.adjustsFontSizeToFitWidth = true
            selectCountryTitleLabel.theme_textColor = GlobalPicker.viewTextColor
        }
    }
    
    var sortedCountryList: [(String, String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
        self.tableViewController.countryTable.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
         self.tableViewController.countryTable.theme_separatorColor = GlobalPicker.tableSeparatorColor
        
        sortedCountryList = GlobalValues.countryList.sorted(by: {$0.1 < $1.1})

        tableViewController.countryTable.delegate = self
        tableViewController.countryTable.dataSource = self
        tableViewController.countryTable.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? countryTableViewController {
            self.tableViewController = tableViewController
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCountryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! AddCoinTableViewCell
        cell.selectionStyle = .none
        cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
        cell.coinImage.image = UIImage.init(named: sortedCountryList[row].1.lowercased())
        cell.coinNameLabel.text = sortedCountryList[row].3
        cell.coinSymbolLabel.text = "(\(sortedCountryList[row].1))"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        Defaults[.selectedCountry] = sortedCountryList[row].0
        GlobalValues.currency = sortedCountryList[row].1
      
      Analytics.logEvent("currency_selected", parameters: [
        "currency": GlobalValues.currency as NSString,
        ])
      
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.theme_backgroundColor = GlobalPicker.viewBackgroundColor
    }
}

class countryTableViewController: UITableViewController {
    
    @IBOutlet var countryTable: UITableView!
}
