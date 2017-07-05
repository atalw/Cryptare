//
//  FirstViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FirstViewController: UIViewController {
    
    @IBOutlet var btcPriceLabel: UILabel!
    @IBOutlet var btcChange: UILabel!
    @IBOutlet var timespan: UILabel!

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var GoogleBannerView: GADBannerView!

    var dataValues: NSArray = []
    let btcPrices = BtcPrices()
    let numberFormatter = NumberFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        self.numberFormatter.locale = Locale.init(identifier: "en_IN")

        self.getCurrentBtcPrice()
        self.populatePrices()
        
        collectionView.dataSource = btcPrices
       
        GoogleBannerView.adUnitID = "ca-app-pub-5797975753570133/6060905008"
        GoogleBannerView.rootViewController = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]

        GoogleBannerView.load(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get current actual price of bitcoin
    func getCurrentBtcPrice() {
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/INR.json")
        
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
            let inrPrice = json?["bpi"] as? [String: Any]
            let inr = inrPrice?["INR"] as? [String: Any]
            let priceString = inr?["rate"] as? String
            let priceWithoutComma = priceString?.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range:nil)
            let price = Double(priceWithoutComma!)

            self.getHistoricalBtcPrices(price!)
            
            DispatchQueue.main.async {
                self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: price!))
                self.timespan.text = "24h"
            }
        }
        task.resume()
    }
    
    // used to calculate percentage change over 24h period (add functionality to change timespan)
    func getHistoricalBtcPrices(_ currentBtcPrice: Double) {
        let current_date = Date()
        let yesterday_date = Calendar.current.date(byAdding: .day, value: -1, to: current_date)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = formatter.string(from: yesterday_date)
        
        let url = URL(string: "http://api.coindesk.com/v1/bpi/historical/close.json?currency=INR")
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
            let inrPrice = json?["bpi"] as? [String: Any]
            let yesterdayBtcPrice = inrPrice?[yesterday] as? Double
            
            let change = currentBtcPrice - yesterdayBtcPrice!
            let percentage = change/yesterdayBtcPrice! * 100
            let roundedPercentage = Double(round(100*percentage)/100)
            DispatchQueue.main.async {
                self.btcChange.text = "\(roundedPercentage) %"
            }
        }
        task.resume()

    }

    // populate exchange buy and sell prices
    func populatePrices() {
        self.zebpayPrice()
        self.unocoinPrice()
        self.localbitcoinsPrice()
        self.coinsecurePrice()
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
            
            let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: zebpayBuyPrice!))
            let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: zebpaySellPrice!))
                        
            self.btcPrices.add("Zebpay")
            self.btcPrices.add(formattedBuyPrice!)
            self.btcPrices.add(formattedSellPrice!)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
            
            let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: unocoinBuyPrice!))
            let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: unocoinSellPrice!))
            
            self.btcPrices.add("Unocoin")
            self.btcPrices.add(formattedBuyPrice!)
            self.btcPrices.add(formattedSellPrice!)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
        task.resume()
    }
    // get localbitcoin buy and sell prices
    func localbitcoinsPrice() {
        let url = URL(string: "https://localbitcoins.com/buy-bitcoins-online/INR/.json")
        var tempBuy: Double = 0.0
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
            let z = y?["temp_price"] as! NSString
            tempBuy = z.doubleValue
            
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
                let z = y?["temp_price"] as! NSString
                let tempSell = z.doubleValue
                
                let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: tempBuy))
                let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: tempSell))
                
                self.btcPrices.add("Localbitcoins")
                self.btcPrices.add(formattedBuyPrice!)
                self.btcPrices.add(formattedSellPrice!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
            sellTask.resume()

            
        }
        task.resume()
    }
    // get coinsecure buy and sell prices
    func coinsecurePrice() {
        let url = URL(string: "https://api.coinsecure.in/v1/exchange/ticker")
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
            let message = json?["message"] as? [String: Any]
            var csBuyPrice = message?["ask"] as? Double
            var csSellPrice = message?["lastPrice"] as? Double
            csBuyPrice = csBuyPrice!/100
            csSellPrice = csSellPrice!/100
            
            let formattedBuyPrice = self.numberFormatter.string(from: NSNumber(value: csBuyPrice!))
            let formattedSellPrice = self.numberFormatter.string(from: NSNumber(value: csSellPrice!))
            
            
            self.btcPrices.add("Coinsecure")
            self.btcPrices.add(formattedBuyPrice!)
            self.btcPrices.add(formattedSellPrice!)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
        task.resume()

    }
    
    
}

