//
//  CountrySelectionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 26/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CountrySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    
    var tableViewController : countryTableViewController!
    @IBOutlet weak var nextButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    
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
        self.defaults.set(sortedCountryList[row].0, forKey: "selectedCountry")
        GlobalValues.currency = sortedCountryList[row].1
        self.dismiss(animated: true, completion: nil)
//        if nextButton != nil {
//            self.nextButton.isEnabled = true
//        }
    }
}

class countryTableViewController: UITableViewController {
    
    @IBOutlet var countryTable: UITableView!
}
