//
//  CountrySelectionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 26/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class CountrySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableViewController : countryTableViewController!
    @IBOutlet weak var nextButton: UIButton!
    
    var sortedCountryList: [(String, String, String, String)] = []
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        #endif
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.createMenuView(storyboard: storyboard)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cell.coinImage.image = UIImage.init(named: sortedCountryList[row].1.lowercased())
        cell.coinNameLabel.text = sortedCountryList[row].3
        cell.coinSymbolLabel.text = "(\(sortedCountryList[row].1))"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        Defaults[.selectedCountry] = sortedCountryList[row].0
        GlobalValues.currency = sortedCountryList[row].1
        self.dismiss(animated: true, completion: nil)
    }
}

class countryTableViewController: UITableViewController {
    
    @IBOutlet var countryTable: UITableView!
}
