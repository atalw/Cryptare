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

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var btcPriceLabel: UILabel!
    @IBOutlet weak var btcChange: UILabel!
    @IBOutlet weak var timespan: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    
    @IBOutlet weak var marketsButton: UIButton!
    @IBOutlet weak var newsButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    let defaults = UserDefaults.standard
    var selectedCountry: String!
  
    let formatter = DateFormatter()

    var currentBtcPrice: Double = 0.0
    var btcChangeColour: UIColor = UIColor.gray
    
    let numberFormatter = NumberFormatter()

    @IBAction func refreshButtonAction(_ sender: Any) {
        self.loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            //            self.present(alert, animated: true){}
            present(alert, animated: true, completion: nil)
        }
        
        self.loadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        self.numberFormatter.numberStyle = NumberFormatter.Style.currency
        if selectedCountry == "india" {
            self.numberFormatter.locale = Locale.init(identifier: "en_IN")
        }
        else if selectedCountry == "usa" {
            self.numberFormatter.locale = Locale.init(identifier: "en_US")
        }
        
        marketsButton.layer.masksToBounds = false
        marketsButton.layer.shadowOpacity = 0.2
        marketsButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        newsButton.layer.masksToBounds = false
        newsButton.layer.shadowOpacity = 0.2
        newsButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        graphButton.layer.masksToBounds = false
        graphButton.layer.shadowOpacity = 0.2
        graphButton.layer.shadowOffset = CGSize(width: 1, height: 1)
//        marketsButton.layer.shadowRadius = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        self.getCurrentBtcPrice()
    }
    
    // get current actual price of bitcoin
    func getCurrentBtcPrice() {
        var url: URL!
        if self.selectedCountry == "india" {
            url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/INR.json")
        }
        else if self.selectedCountry == "usa" {
            url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice/USD.json")
        }
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            let json = JSON(data: data)
            if self.selectedCountry == "india" {
                if let priceString = json["bpi"]["INR"]["rate"].string {
                    let priceWithoutComma = priceString.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range:nil)
                    let price = Double(priceWithoutComma)
                    self.currentBtcPrice = price!
                    self.getHistoricalBtcPrices(price!)
                    DispatchQueue.main.async {
                        self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: price!))
                        self.btcPriceLabel.adjustsFontSizeToFitWidth = true
                        self.timespan.text = "(24h)"
                        self.formatter.dateFormat = "h:mm a"
                        self.lastUpdated.text = self.formatter.string(from: Date())
                    }
                }
                else {
                    print(json["bpi"]["INR"]["rate"].error!)
                }
            }
            else if self.selectedCountry == "usa" {
                if let priceString = json["bpi"]["USD"]["rate"].string {
                    let priceWithoutComma = priceString.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range:nil)
                    let price = Double(priceWithoutComma)
                    self.currentBtcPrice = price!
                    self.getHistoricalBtcPrices(price!)
                    DispatchQueue.main.async {
                        self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: price!))
                        self.btcPriceLabel.adjustsFontSizeToFitWidth = true
                        self.timespan.text = "(24h)"
                        self.formatter.dateFormat = "h:mm a"
                        self.lastUpdated.text = self.formatter.string(from: Date())
                    }
                }
                else {
                    print(json["bpi"]["USD"]["rate"].error!)
                }
            }
            
        }
        task.resume()
    }

    func updateCurrentBtcPrice(_ value: Double) {
        self.btcPriceLabel.text = self.numberFormatter.string(from: NSNumber(value: value))
    }
    
    // used to calculate percentage change over 24h period (add functionality to change timespan)
    func getHistoricalBtcPrices(_ currentBtcPrice: Double) {
        let current_date = Date()
        let yesterday_date = Calendar.current.date(byAdding: .day, value: -1, to: current_date)!
        // sometimes takes time for source website to update closing price of day before (probably due to time difference)
        let day_before_yesterday_date = Calendar.current.date(byAdding: .day, value: -2, to: current_date)!
        self.formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = formatter.string(from: yesterday_date)
        let day_before_yesterday = formatter.string(from: day_before_yesterday_date)
        
        var url: URL!
        if self.selectedCountry == "india" {
            url = URL(string: "http://api.coindesk.com/v1/bpi/historical/close.json?currency=INR")
        }
        else if self.selectedCountry == "usa" {
            url = URL(string: "http://api.coindesk.com/v1/bpi/historical/close.json?currency=USD")
        }
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let inrPrice = json?["bpi"] as? [String: Any]
                let yesterdayBtcPrice = inrPrice?[yesterday] as? Double ?? inrPrice?[day_before_yesterday] as? Double
                let change = currentBtcPrice - yesterdayBtcPrice!
                let percentage = change/yesterdayBtcPrice! * 100
                let roundedPercentage = Double(round(100*percentage)/100)
                DispatchQueue.main.async {
                    if roundedPercentage > 0 {
                        self.btcChange.text = "+\(roundedPercentage)%"
                    }
                    else {
                        self.btcChange.text = "\(roundedPercentage)%"
                    }
                    self.btcChange.layer.masksToBounds = true
                    self.btcChange.layer.cornerRadius = 8
                    self.btcChange.textColor = UIColor.white
                    if roundedPercentage < 0 {
                        self.btcChange.backgroundColor = self.hexStringToUIColor(hex: "#e74c3c")
                        self.btcChangeColour = self.hexStringToUIColor(hex: "#e74c3c")
                    }
                    else if roundedPercentage > 0 {
                        self.btcChange.backgroundColor = self.hexStringToUIColor(hex: "#2ecc71")
                        self.btcChangeColour = self.hexStringToUIColor(hex: "#2ecc71")
                    }
                    
                }
                
            }
            catch {
                print("Error")
            }
        }
        task.resume()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination
        if let graphController = destinationViewController as? GraphViewController {
            graphController.btcPrice = self.btcPriceLabel.text!
            graphController.btcPriceChange = self.btcChange.text!
            graphController.btcChangeColour = self.btcChangeColour
        }
        else if let marketController = destinationViewController as? MarketViewController {
            marketController.currentBtcPriceString = self.btcPriceLabel.text!
            marketController.currentBtcPrice = self.currentBtcPrice
        }
    }

}
