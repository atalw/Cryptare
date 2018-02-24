//
//  UnlockMarketsViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 24/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class UnlockMarketsViewController: UIViewController {

    @IBOutlet weak var proLabel: UILabel!
    
    @IBOutlet weak var buyUnlockMarketsButton: UIButton!
    let greenColour = UIColor.init(hex: "#2ecc71")
    
    @IBOutlet weak var featureOneLabel: UILabel!
    @IBOutlet weak var featureTwoLabel: UILabel!
    @IBOutlet weak var featureThreeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        proLabel.adjustsFontSizeToFitWidth = true
        
        self.buyUnlockMarketsButton.backgroundColor = greenColour
        self.buyUnlockMarketsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        featureOneLabel.adjustsFontSizeToFitWidth = true
        featureTwoLabel.adjustsFontSizeToFitWidth = true
        featureThreeLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.buyUnlockMarketsButton.titleLabel?.textAlignment = .center

        IAPService.shared.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
            if success {
                if products != nil {
                    let price = products![1].localizedPrice()
                    self.buyUnlockMarketsButton.setTitle(" Unlock all markets for a one-time lifetime purchase of \(price). ", for: .normal)
                    self.buyUnlockMarketsButton.titleLabel?.lineBreakMode = .byWordWrapping
                    self.buyUnlockMarketsButton.addTarget(self, action: #selector(self.unlockMarketsButtonTapped), for: .touchUpInside)
                }
            }
        })
    }

    @objc func unlockMarketsButtonTapped() {
        IAPService.shared.purchase(product: .unlockMarkets, completionHandlerBool: { (success) -> Void in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
