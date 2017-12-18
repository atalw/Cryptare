//
//  DashboardViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/08/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SwiftyJSON
import Hero
import SlideMenuControllerSwift
import Firebase

class DashboardViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    let coins = ["BTC", "LTC", "ETH", "XRP"]
    let greenColour = UIColor.init(hex: "#2ecc71")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var graphController: GraphViewController! // child view controller
    
    var currentBtcPrice: Double!
    var currentLtcPrice: Double!
    var currentEthPrice: Double!
    
    var coinData: [String: [String: Any]] = [:]
    
    @IBOutlet weak var tableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var coinRefs: [DatabaseReference] = []

    @IBAction func refreshButtonAction(_ sender: Any) {
        graphController.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for coin in coins {
            coinData[coin] = [:]
            coinData[coin]!["currentPrice"] = 0.0
            coinData[coin]!["timestamp"] = 0.0
            coinData[coin]!["volume24hrs"] = 0.0
            coinData[coin]!["percentageChange24hrs"] = 0.0
        }
        
        let currency = GlobalValues.currency!
        
        if currency == "INR" {
            numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if currency == "USD" {
            numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        databaseRef = Database.database().reference()
        
        for coin in coins {
            coinRefs.append(databaseRef.child("current_\(coin)_price_\(currency)"))
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            //            self.present(alert, animated: true){}
            present(alert, animated: true, completion: nil)
        }
//        graphController.reloadData()
        
        for coinRef in coinRefs {
            coinRef.queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let index = self.coinRefs.index(of: coinRef)
                    let coin = self.coins[index!]
                    self.updateCoinDataStructure(coin: coin, dict: dict)
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        marketsButton.colourOne = UIColor.init(hex: "#2F80ED")
//        marketsButton.colourTwo = UIColor.init(hex: "#56CCF2")
//
//        newsButton.colourOne = UIColor.init(hex: "#fc4a1a")
//        newsButton.colourTwo = UIColor.init(hex: "#f7b733")
        
        numberFormatter.numberStyle = .currency
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        databaseRef.removeAllObservers()
        
        for coinRef in coinRefs {
            coinRef.removeAllObservers()
        }
        
        coinRefs = []
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination
        if let graphController = destinationViewController as? GraphViewController {
            graphController.parentControler = self
            self.graphController = graphController
        }
    }
    
    func updateCoinDataStructure(coin: String, dict: [String: Any]) {
        if self.coinData[coin]!["oldPrice"] == nil {
            self.coinData[coin]!["oldPrice"] = 0.0
        }
        else {
            self.coinData[coin]!["oldPrice"] = self.coinData[coin]!["currentPrice"]
        }
        
        self.coinData[coin]!["currentPrice"] = dict["price"] as! Double
        self.coinData[coin]!["volume24hrs"] = dict["vol_24hrs_\(GlobalValues.currency)!"]
        self.coinData[coin]!["percentageChange24hrs"] = dict["percentage_change_24h"] as! Double
        self.coinData[coin]!["timestamp"] = dict["timestamp"] as! Double
        self.tableView.reloadData()
    }

}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("here")
        
        let coin = coins[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "coinCell") as? CoinTableViewCell
        
        cell!.coinSymbolLabel.text = coin
        cell!.coinSymbolImage.image = UIImage(named: coin.lowercased())
        cell!.coinSymbolImage.contentMode = .scaleAspectFit
        
        var colour: UIColor
        let currentPrice = self.coinData[coin]?["currentPrice"] as! Double
        let oldPrice = self.coinData[coin]?["oldPrice"] as? Double ?? 0.0
        
        if  currentPrice > oldPrice {
            colour = self.greenColour
        }
        else if currentPrice < oldPrice {
            colour = self.redColour
        }
        else {
            colour = UIColor.black
        }
        cell!.coinCurrentValueLabel.text = self.numberFormatter.string(from: NSNumber(value: currentPrice))
        
        UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
             cell!.coinCurrentValueLabel.textColor = colour
        }, completion: { finished in
            UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 1.5, options: .transitionCrossDissolve, animations: {
                 cell!.coinCurrentValueLabel.textColor = UIColor.black
            }, completion: nil)
        })
        
        self.dateFormatter.dateFormat = "h:mm a"
        let timestamp = self.coinData[coin]?["timestamp"] as! Double
        cell!.coinTimestampLabel.text =  self.dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
        
        let percentageChange = self.coinData[coin]?["percentageChange24hrs"] as! Double
        cell!.coinPercentageChangeLabel.text = "\(percentageChange)%"
        
        if percentageChange > 0 {
            cell!.coinPercentageChangeLabel.textColor = greenColour
        }
        else if percentageChange < 0 {
             cell!.coinPercentageChangeLabel.textColor = redColour
        }
        else {
             cell!.coinPercentageChangeLabel.textColor = UIColor.black
        }
        
        return cell!
    }
    
}

extension DashboardViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
//        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
//        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
//        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
//        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
//        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
//        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
//        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
//        print("SlideMenuControllerDelegate: rightDidClose")
    }
}


