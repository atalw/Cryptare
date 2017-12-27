//
//  AddCoinTableViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 27/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Firebase

class AddCoinTableViewController: UITableViewController {
    
    var databaseRef: DatabaseReference!
    var listOfCoins: DatabaseReference!
    
    var coins: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseRef = Database.database().reference()
        
        listOfCoins = databaseRef.child("coins")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        listOfCoins.queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: AnyObject] {
                let sortedDict = dict.sorted(by: { ($0.1["rank"] as! Int) < ($1.1["rank"] as! Int)})
                self.coins = []
                for index in 0..<sortedDict.count {
                    if sortedDict[index].key != "MIOTA" && sortedDict[index].key != "VET" {
                        let coin = sortedDict[index].key
                        let coinName = sortedDict[index].value["name"] as! String
                        self.coins.append((coin, coinName))
                    }
                    else if sortedDict[index].key == "MIOTA" {
                        self.coins.append(("IOT", "IOTA"))
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCoinCell", for: indexPath) as! AddCoinTableViewCell
        
        let index = indexPath.row
        print(coins[index].0.lowercased())
        if coins[index].0 == "IOT" {
            cell.coinImage.image = UIImage(named: "miota")
        }
        else {
            cell.coinImage.image = UIImage(named: coins[index].0.lowercased())
        }
        cell.coinNameLabel.text = coins[index].1
        cell.coinSymbolLabel.text = "(\(coins[index].0))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "coinDetailPortfolioController") as! PortfolioViewController

        targetViewController.coin = coins[indexPath.row].0
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.pushViewController(targetViewController, animated: true)

    }
 

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
