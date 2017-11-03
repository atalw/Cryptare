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

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var marketsButton: GradientView!
    @IBOutlet weak var newsButton: GradientView!
    
    var graphController: GraphViewController! // child view controller
    var currentBtcPrice: Double = 0.0
    var currentBtcPriceString: String!

    @IBAction func refreshButtonAction(_ sender: Any) {
        graphController.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in }  )
            //            self.present(alert, animated: true){}
            present(alert, animated: true, completion: nil)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        marketsButton.colourOne = UIColor.init(hex: "#2F80ED")
        marketsButton.colourTwo = UIColor.init(hex: "#56CCF2")
        
        newsButton.colourOne = UIColor.init(hex: "#fc4a1a")
        newsButton.colourTwo = UIColor.init(hex: "#f7b733")
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        else if let marketController = destinationViewController as? MarketViewController {
            print(self.currentBtcPrice)
            if self.currentBtcPriceString != nil || self.currentBtcPrice != nil {
                marketController.currentBtcPriceString = self.currentBtcPriceString
                marketController.currentBtcPrice = self.currentBtcPrice
            }
            
        }
    }

}

extension DashboardViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}


