//
//  CountrySelectionViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 26/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class CountrySelectionViewController: UIViewController, UITableViewDelegate {
    
    var tableViewController : countryTableViewController!
    @IBOutlet weak var nextButton: UIButton!
    
    let defaults = UserDefaults.standard
    
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

        // Do any additional setup after loading the view.
//        self.tableViewController.countryTable.sel
        self.tableViewController.countryTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        if let tableViewController = segue.destination as? countryTableViewController {
            self.tableViewController = tableViewController
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.defaults.set("india", forKey: "selectedCountry")
            GlobalValues.currency = "INR"
        }
        else if indexPath.row == 1 {
            self.defaults.set("usa", forKey: "selectedCountry")
            GlobalValues.currency = "USD"
        }
        if nextButton != nil {
            self.nextButton.isEnabled = true
        }
    }
}

class countryTableViewController: UITableViewController {
    
    @IBOutlet var countryTable: UITableView!
    @IBOutlet weak var indiaCell: UITableViewCell!
}
