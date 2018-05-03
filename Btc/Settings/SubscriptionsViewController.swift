//
//  UnlockMarketsViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 24/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController {
  
  let greenColour = UIColor.init(hex: "#2ecc71")
  let darkerGreenColour = UIColor.init(hex: "#29b765")
  
  @IBOutlet weak var proLabel: UILabel!
  
  @IBOutlet weak var buyProModeOneMonth: UIButton! {
    didSet {
      self.buyProModeOneMonth.backgroundColor = greenColour
      self.buyProModeOneMonth.titleLabel?.textAlignment = .center
      self.buyProModeOneMonth.titleLabel?.adjustsFontSizeToFitWidth = true
      self.buyProModeOneMonth.titleLabel?.textAlignment = NSTextAlignment.center
//      self.buyProModeOneMonth.titleLabel?.lineBreakMode = .byWordWrapping
      self.buyProModeOneMonth.contentVerticalAlignment = .center
//      self.buyProModeOneMonth.addTarget(self, action: #selector(self.unlockProModeTapped), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var buyProModeOneYear: UIButton! {
    didSet {
      self.buyProModeOneYear.backgroundColor = darkerGreenColour
      self.buyProModeOneYear.titleLabel?.textAlignment = .center
      self.buyProModeOneYear.titleLabel?.adjustsFontSizeToFitWidth = true
      self.buyProModeOneYear.titleLabel?.textAlignment = NSTextAlignment.center
      //      self.buyProModeOneYear.titleLabel?.lineBreakMode = .byWordWrapping
      self.buyProModeOneYear.contentVerticalAlignment = .center
      //      self.buyProModeOneYear.addTarget(self, action: #selector(self.unlockProModeOneYearTapped), for: .touchUpInside)
    }
  }
  
  
  @IBOutlet weak var priceOneYearLabel: UILabel!
  @IBOutlet weak var priceSixMonthsLabel: UILabel!
  @IBOutlet weak var priceOneMonthLabel: UILabel!

  @IBOutlet weak var oneYearView: UIView! {
    didSet {
      let oneYearGesture = UITapGestureRecognizer(target: self, action:  #selector(unlockProModeOneYearTapped(sender:)))
      oneYearView.addGestureRecognizer(oneYearGesture)
    }
  }
  @IBOutlet weak var sixMonthsView: UIView! {
    didSet {
      let sixMonthsGesture = UITapGestureRecognizer(target: self, action:  #selector(unlockProModeSixMonthsTapped(sender:)))
      sixMonthsView.addGestureRecognizer(sixMonthsGesture)
    }
  }
  @IBOutlet weak var oneMonthView: UIView! {
    didSet {
      let oneMonthGesture = UITapGestureRecognizer(target: self, action:  #selector(unlockProModeOneMonthTapped(sender:)))
      oneMonthView.addGestureRecognizer(oneMonthGesture)
    }
  }
  
  @IBOutlet weak var featureOneLabel: UILabel! {
    didSet {
      featureOneLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var featureTwoLabel: UILabel! {
    didSet {
      featureTwoLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var featureThreeLabel: UILabel! {
    didSet {
      featureThreeLabel.adjustsFontSizeToFitWidth = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    FirebaseService.shared.updateScreenName(screenName: "Subscriptions", screenClass: "SubscriptionsViewController")
    
    proLabel.adjustsFontSizeToFitWidth = true
    
    IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
      if success {
        if products != nil {
          var price = 0.0.asCurrency
          for product in products! {
            if product.productIdentifier == IAPProduct.unlockProMode.rawValue {
              price = product.localizedPrice()
              self.priceOneMonthLabel.text = "\(price) / Mo"
              
            }
            else if product.productIdentifier == IAPProduct.unlockProModeSixMonths.rawValue {
              price = product.localizedPrice()
              let locale = product.priceLocale
              let priceRaw = product.price
              let monthlyPrice = Double(truncating: (priceRaw as Decimal)/6 as NSNumber)
              self.priceSixMonthsLabel.text = "\(monthlyPrice.asCurrencyWith(locale: locale)) / Mo"
            }
            else if product.productIdentifier == IAPProduct.unlockProModeOneYear.rawValue {
              price = product.localizedPrice()
              let locale = product.priceLocale
              let priceRaw = product.price
              let monthlyPrice = Double(truncating: (priceRaw as Decimal)/12 as NSNumber)
              self.priceOneYearLabel.text = "\(monthlyPrice.asCurrencyWith(locale: locale)) / Mo"
            }
          }
        }
      }
    })
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    FirebaseService.shared.subscription_page_opened()
  }
  
  @objc func unlockProModeOneYearTapped(sender : UITapGestureRecognizer) {
    FirebaseService.shared.one_year_subscription_tapped()
    
    IAPService.shared.purchase(product: .unlockProModeOneYear, completionHandlerBool: { (success) -> Void in
      if success {
        self.dismiss(animated: true, completion: nil)
      }
    })
  }
  
  @objc func unlockProModeSixMonthsTapped(sender : UITapGestureRecognizer) {
    FirebaseService.shared.six_months_subscription_tapped()
    
    IAPService.shared.purchase(product: .unlockProModeSixMonths, completionHandlerBool: { (success) -> Void in
      if success {
        self.dismiss(animated: true, completion: nil)
      }
    })
  }
  
  @objc func unlockProModeOneMonthTapped(sender : UITapGestureRecognizer) {
    FirebaseService.shared.one_month_subscription_tapped()
    
    IAPService.shared.purchase(product: .unlockProMode, completionHandlerBool: { (success) -> Void in
      if success {
        self.dismiss(animated: true, completion: nil)
      }
    })
  }
  
  @IBAction func closeButtonTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func tosButtonTapped(_ sender: Any) {
    FirebaseService.shared.tos_tapped_from_subscription()
    
    if let url = URL(string: "http://cryptare.io/privacy.html") {
      UIApplication.shared.openURL(url)
    }
  }
  @IBAction func privacyButtonTapped(_ sender: Any) {
    FirebaseService.shared.privacy_tapped_from_subscription()
    
    if let url = URL(string: "http://cryptare.io/tos.html") {
      UIApplication.shared.openURL(url)
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
