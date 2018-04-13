//
//  UnlockMarketsViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 24/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class UnlockMarketsViewController: UIViewController {
  
  let greenColour = UIColor.init(hex: "#2ecc71")
  
  @IBOutlet weak var proLabel: UILabel!
  
  @IBOutlet weak var buyProModeOneMonth: UIButton! {
    didSet {
      self.buyProModeOneMonth.backgroundColor = greenColour
      self.buyProModeOneMonth.titleLabel?.textAlignment = .center
      self.buyProModeOneMonth.titleLabel?.adjustsFontSizeToFitWidth = true
      self.buyProModeOneMonth.titleLabel?.textAlignment = NSTextAlignment.center
//      self.buyProModeOneMonth.titleLabel?.lineBreakMode = .byWordWrapping
      self.buyProModeOneMonth.contentVerticalAlignment = .center
      self.buyProModeOneMonth.addTarget(self, action: #selector(self.unlockProModeTapped), for: .touchUpInside)
    }
  }
  @IBOutlet weak var buyProModeOneYear: UIButton! {
    didSet {
      self.buyProModeOneYear.backgroundColor = greenColour
      self.buyProModeOneYear.titleLabel?.textAlignment = .center
      self.buyProModeOneYear.titleLabel?.adjustsFontSizeToFitWidth = true
      self.buyProModeOneYear.titleLabel?.textAlignment = NSTextAlignment.center
//      self.buyProModeOneYear.titleLabel?.lineBreakMode = .byWordWrapping
      self.buyProModeOneYear.contentVerticalAlignment = .center
      self.buyProModeOneYear.addTarget(self, action: #selector(self.unlockProModeOneYearTapped), for: .touchUpInside)
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
    
    proLabel.adjustsFontSizeToFitWidth = true
    
    IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
      if success {
        if products != nil {
          var price = 0.0.asCurrency
          for product in products! {
            if product.productIdentifier == IAPProduct.unlockProMode.rawValue {
              price = product.localizedPrice()
              self.buyProModeOneMonth.setTitle("\(price) / Month \nBilled Monthly", for: .normal)

            }
            else if product.productIdentifier == IAPProduct.unlockProModeOneYear.rawValue {
              price = product.localizedPrice()
              let priceRaw = product.price
              let monthlyPrice = Double((priceRaw as Decimal)/12 as NSNumber)
              self.buyProModeOneYear.setTitle("\(monthlyPrice.asCurrency) / Month \nBilled Annually", for: .normal)
            }
          }
        }
      }
    })
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  @objc func unlockProModeTapped() {
    IAPService.shared.purchase(product: .unlockProMode, completionHandlerBool: { (success) -> Void in
      if success {
        self.dismiss(animated: true, completion: nil)
      }
    })
  }
  
  @objc func unlockProModeOneYearTapped() {
    IAPService.shared.purchase(product: .unlockProModeOneYear, completionHandlerBool: { (success) -> Void in
      if success {
        self.dismiss(animated: true, completion: nil)
      }
    })
  }
  
  @IBAction func closeButtonTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func tosButtonTapped(_ sender: Any) {
    if let url = URL(string: "http://cryptare.io/privacy.html") {
      UIApplication.shared.openURL(url)
    }
  }
  @IBAction func privacyButtonTapped(_ sender: Any) {
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
