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
        print(indexPath)
        self.nextButton.isEnabled = true
    }
}

class countryTableViewController: UITableViewController {
    
    @IBOutlet var countryTable: UITableView!
    @IBOutlet weak var indiaCell: UITableViewCell!
}
