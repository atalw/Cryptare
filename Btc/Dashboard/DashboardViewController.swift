//
//  DashboardViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 19/08/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Firebase

class DashboardViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    
    var coins: [String] = []
    let greenColour = UIColor.init(hex: "#35CC4B")
    let redColour = UIColor.init(hex: "#e74c3c")
    
    var graphController: GraphViewController! // child view controller
    
    var coinData: [String: [String: Any]] = [:]
    var changedRow = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var listOfCoins: DatabaseReference!
    var coinRefs: [DatabaseReference] = []
    
    @IBOutlet weak var header24hrChangeLabel: UILabel!
    @IBOutlet weak var headerCurrentPriceLabel: UILabel!
    
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currency = GlobalValues.currency!
        
        databaseRef = Database.database().reference()
        
        listOfCoins = databaseRef.child("coins")
        
        currencyButton.title = currency
        
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
        
        listOfCoins.queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: AnyObject] {
                let sortedDict = dict.sorted(by: { ($0.1["rank"] as! Int) < ($1.1["rank"] as! Int)})
                self.coins = []
                GlobalValues.coins = []
                for index in 0..<sortedDict.count {
                    self.coins.append(sortedDict[index].key)
                    GlobalValues.coins.append((sortedDict[index].key, sortedDict[index].value["name"] as! String))
                }
                self.setupCoinRefs()
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        marketsButton.colourOne = UIColor.init(hex: "#2F80ED")
//        marketsButton.colourTwo = UIColor.init(hex: "#56CCF2")
//
//        newsButton.colourOne = UIColor.init(hex: "#fc4a1a")
//        newsButton.colourTwo = UIColor.init(hex: "#f7b733")
        
        tableView.delegate = self
        tableView.dataSource = self
        
////        header24hrChangeLabel.adjustsFontSizeToFitWidth = true
//        headerCurrentPriceLabel.adjustsFontSizeToFitWidth = true
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        databaseRef.removeAllObservers()
        listOfCoins.removeAllObservers()
        
        for coinRef in coinRefs {
            coinRef.removeAllObservers()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination
        if let graphController = destinationViewController as? GraphViewController {
//            graphController.parentControler = self
            self.graphController = graphController
        }
    }
    
    func setupCoinRefs() {
        let currency = GlobalValues.currency!
        coinData = [:]
        for coin in self.coins {
            self.coinData[coin] = [:]
            self.coinData[coin]!["rank"] = 0
            self.coinData[coin]!["currentPrice"] = 0.0
            self.coinData[coin]!["timestamp"] = 0.0
            self.coinData[coin]!["volume24hrs"] = 0.0
            self.coinData[coin]!["percentageChange24hrs"] = 0.0
            self.coinData[coin]!["priceChange24hrs"] = 0.0
        }
        coinRefs = []
        for coin in self.coins {
            self.coinRefs.append(self.databaseRef.child(coin))
        }
        
        for coinRef in self.coinRefs {
            coinRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let index = self.coinRefs.index(of: coinRef)
                    let coin = self.coins[index!]
                    self.changedRow = index!
                    self.updateCoinDataStructure(coin: coin, dict: dict)
                }
            })
            
            coinRef.observe(.childChanged, with: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String : AnyObject] {
                    if let index = self.coinRefs.index(of: coinRef) {
                        let coin = self.coins[index]
                        self.changedRow = index
                        self.updateCoinDataStructure(coin: coin, dict: dict)
                    }
                }
            })
        }
    }
    
    func updateCoinDataStructure(coin: String, dict: [String: Any]) {
        self.coinData[coin]!["rank"] = dict["rank"] as! Int
        
        if let currencyData = dict[GlobalValues.currency!] as? [String: Any] {
            if self.coinData[coin]!["oldPrice"] == nil {
                self.coinData[coin]!["oldPrice"] = 0.0
            }
            else {
                self.coinData[coin]!["oldPrice"] = self.coinData[coin]!["currentPrice"]
            }
            self.coinData[coin]!["currentPrice"] = currencyData["price"] as! Double
            self.coinData[coin]!["volume24hrs"] = currencyData["vol_24hrs_currency"]
            let percentage = currencyData["change_24hrs_percent"] as! Double
            let roundedPercentage = Double(round(1000*percentage)/1000)
            self.coinData[coin]!["percentageChange24hrs"] = roundedPercentage
            self.coinData[coin]!["priceChange24hrs"] = currencyData["change_24hrs_fiat"] as! Double
            self.coinData[coin]!["timestamp"] = currencyData["timestamp"] as! Double
            self.tableView.reloadData()
        }
        
    }
    
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin = coins[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "coinCell") as? CoinTableViewCell
        
        cell!.coinRank.text = "\(self.coinData[coin]?["rank"] as! Int)"
        cell!.coinRank.adjustsFontSizeToFitWidth = true
        
        cell!.coinSymbolLabel.text = coin
        cell!.coinSymbolLabel.adjustsFontSizeToFitWidth = true
        
        if coin == "IOT" {
            cell!.coinSymbolImage.image = UIImage(named: "miota")
        }
        else {
            cell!.coinSymbolImage.image = UIImage(named: coin.lowercased())
        }
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
        
        cell!.coinCurrentValueLabel.adjustsFontSizeToFitWidth = true
        cell!.coinCurrentValueLabel.text = currentPrice.asCurrency
        if changedRow == indexPath.row {
            UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
                cell!.coinCurrentValueLabel.textColor = colour
            }, completion: { finished in
                UILabel.transition(with:  cell!.coinCurrentValueLabel, duration: 1.5, options: .transitionCrossDissolve, animations: {
                    cell!.coinCurrentValueLabel.textColor = UIColor.black
                }, completion: nil)
            })
            
            changedRow = -1
        }
        
        
        self.dateFormatter.dateFormat = "h:mm a"
        let timestamp = self.coinData[coin]?["timestamp"] as! Double
        cell!.coinTimestampLabel.text =  self.dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
        cell!.coinTimestampLabel.adjustsFontSizeToFitWidth = true
        
        let percentageChange = self.coinData[coin]?["percentageChange24hrs"] as! Double
        cell!.coinPercentageChangeLabel.text = "\(percentageChange)%"
        
        if percentageChange > 0 {
            cell!.coinPercentageChangeLabel.textColor = greenColour
            colour = greenColour
        }
        else if percentageChange < 0 {
             cell!.coinPercentageChangeLabel.textColor = redColour
            colour = redColour
        }
        else {
             cell!.coinPercentageChangeLabel.textColor = UIColor.black
            colour = UIColor.black
        }
        
        let priceChange = self.coinData[coin]?["priceChange24hrs"] as! Double
        cell!.coinPriceChangeLabel.text = priceChange.asCurrency
        cell!.coinPriceChangeLabel.adjustsFontSizeToFitWidth = true
        cell!.coinPriceChangeLabel.textColor = colour
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetViewController = storyboard?.instantiateViewController(withIdentifier: "graphViewController") as! GraphViewController
        targetViewController.databaseTableTitle = self.coins[indexPath.row]
        self.navigationController?.pushViewController(targetViewController, animated: true)
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


