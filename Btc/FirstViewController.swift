//
//  FirstViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
//import PlaygroundSupport


class FirstViewController: UIViewController {
    
    @IBOutlet var btcPriceTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    
    var dataValues: NSArray = []
    let btcPrices = BtcPrices()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.getCurrentBtcPrice()
        self.populatePrices()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = btcPrices
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get current actual price of bitcoin
    func getCurrentBtcPrice() {
        let url = URL(string: "https://blockchain.info/ticker")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            let inrPrice = json?["INR"] as? [String: Any]
            //            print(price)
            let symbol = inrPrice?["symbol"] as? String
            let price = inrPrice?["buy"] as? Double
            self.btcPriceTextField.text = String.localizedStringWithFormat("%@ %.2f", symbol!,price!)
            
        }
        task.resume()
    }

    // populate exchange buy and sell prices
    func populatePrices() {
        self.zebpayPrice()
        self.unocoinPrice()
        self.localbitcoinsPrice()
    }
    
    // get zebpay buy and sell prices
    func zebpayPrice() {
        let url = URL(string: "https://api.zebpay.com/api/v1/ticker?currencyCode=INR")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            let zebpayBuyPrice = json?["buy"] as? Double
            let zebpaySellPrice = json?["sell"] as? Double
            self.btcPrices.add("Zebpay ₹ \(zebpayBuyPrice ?? 0) ₹ \(zebpaySellPrice ?? 0)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        task.resume()
    }
    // get unocoin buy and sell prices
    func unocoinPrice() {
        let url = URL(string: "https://www.unocoin.com/trade?all")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            let unocoinBuyPrice = json?["buy"] as? Double
            let unocoinSellPrice = json?["sell"] as? Double
            self.btcPrices.add("Unocoin ₹ \(unocoinBuyPrice ?? 0) ₹ \(unocoinSellPrice ?? 0)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        task.resume()
    }
    // get localbitcoin buy and sell prices
    func localbitcoinsPrice() {
        let url = URL(string: "https://localbitcoins.com/buy-bitcoins-online/INR/.json")
        var tempBuy: Any = 0.0
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            
            let localBuyPrice = json?["data"] as? [String: Any]
            let x = localBuyPrice?["ad_list"] as? [[String: Any]]
            let y = x?[0]["data"] as? [String: Any]
            let z = y?["temp_price"]
            tempBuy = z ?? 0
            
            let sellUrl = URL(string: "https://localbitcoins.com/sell-bitcoins-online/INR/.json")
            let sellTask = URLSession.shared.dataTask(with: sellUrl!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                
                let localBuyPrice = json?["data"] as? [String: Any]
                let x = localBuyPrice?["ad_list"] as? [[String: Any]]
                let y = x?[0]["data"] as? [String: Any]
                let z = y?["temp_price"]
                //            let unocoinSellPrice = json?["sell"] as? Double
                self.btcPrices.add("LocalBitcoin ₹ \(tempBuy ?? 0) ₹ \(z ?? 0)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            sellTask.resume()

            
        }
        task.resume()
    }
    
}

