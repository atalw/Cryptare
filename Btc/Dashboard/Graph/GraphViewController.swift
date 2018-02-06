//
//  GraphViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 12/09/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import TTSegmentedControl

class GraphViewController: UIViewController {
    
    var parentControler: DashboardViewController!
    
    var databaseTableTitle: String!
    
    @IBOutlet weak var viewSegmentControl: TTSegmentedControl!
    
    @IBOutlet weak var pageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var cryptoDetailContainer: UIView!
    @IBOutlet weak var newsContainer: UIView!
    @IBOutlet weak var marketContainer: UIView!
    
    @IBAction func viewSegmentChanged(_ sender: Any) {
        
        switch (sender as? UISegmentedControl)!.selectedSegmentIndex {
        case 0:
            cryptoDetailContainer.isHidden = false
            newsContainer.isHidden = true
            marketContainer.isHidden = true
        case 1:
            cryptoDetailContainer.isHidden = true
            newsContainer.isHidden = false
            marketContainer.isHidden = true
        case 2:
            cryptoDetailContainer.isHidden = true
            newsContainer.isHidden = true
            marketContainer.isHidden = false
        default:
            break;
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSegmentControl.allowChangeThumbWidth = false
        
        viewSegmentControl.itemTitles = ["Details", "News", "Markets"]
        viewSegmentControl.defaultTextFont = UIFont.boldSystemFont(ofSize: 15)
        viewSegmentControl.selectedTextFont = UIFont.boldSystemFont(ofSize: 15)
        
        viewSegmentControl.didSelectItemWith = { (index, title) -> () in
            if index == 0 {
                self.cryptoDetailContainer.isHidden = false
                self.newsContainer.isHidden = true
                self.marketContainer.isHidden = true
            }
            else if index == 1 {
                self.cryptoDetailContainer.isHidden = true
                self.newsContainer.isHidden = false
                self.marketContainer.isHidden = true
            }
            else if index == 2 {
                self.cryptoDetailContainer.isHidden = true
                self.newsContainer.isHidden = true
                self.marketContainer.isHidden = false
            }
        }
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        pageSegmentedControl.selectedSegmentIndex = 0
        
        cryptoDetailContainer.isHidden = false
        newsContainer.isHidden = true
        marketContainer.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationViewController = segue.destination
        
        if let cryptoDetailViewController = segue.destination as? CryptoDetailViewController {
            cryptoDetailViewController.databaseTableTitle = databaseTableTitle
        }
        else if let newsViewController = segue.destination as? NewsViewController {
            for (symbol, name) in GlobalValues.coins {
                if symbol == databaseTableTitle {
                    let searchTerm = "\(name) \(symbol) cryptocurrency"
                    newsViewController.cryptoName = searchTerm

                }
            }
        }
        else if let marketViewController = segue.destination as? MarketViewController {
            marketViewController.currentCoin = databaseTableTitle
        }
        
    }
    
}
