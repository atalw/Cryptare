//
//  BtcPrices.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class BtcPrices: NSObject {
    fileprivate var items: [String] = []
    
    func add(_ item: String) {
        items.append(item)
    }
    
    func getItems() -> [String] {
        return self.items
    }
    
    func updateItems(_ element: String, index: Int) {
        self.items[index] = element
    }
    
}

extension BtcPrices: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! MyCollectionViewCell
        let item = items[indexPath.item]
        cell.myButton.setTitle(item, for: .normal)
        cell.myButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.myButton.isEnabled = false
        cell.myButton.setTitleColor(UIColor.black, for: .normal)
        cell.myButton.backgroundColor = UIColor.white
        
        if item == "Zebpay" || item == "Unocoin" || item == "Localbitcoins" || item == "Coinsecure" {
            cell.myButton.isEnabled = true
            //            cell.myButton.setTitleColor(UIColor.blue, for: .normal)
            cell.myButton.setTitleColor(UIColor.white, for: .normal)
            cell.myButton.backgroundColor = hexStringToUIColor(hex: "#5790E2")
            cell.myButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            cell.myButton.layer.cornerRadius = 8
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionViewHeader
            headerView.siteLabel.text = "Site"
            headerView.buyLabel.text = "Buy"
            headerView.sellLabel.text = "Sell"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func buttonAction(sender: UIButton!) {
        
        let title = sender.title(for: .normal)
        
        if title == "Zebpay" {
            if let url = NSURL(string: "https://www.zebpay.com/?utm_campaign=app_refferal_ref/ref/REF34005162&utm_medium=app&utm_source=zebpay_app_refferal"){ if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
                
                } }
            
        }
        else if title == "Unocoin" {
            if let url = NSURL(string: "https://www.unocoin.com/"){ if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
                
                } }
        }
        else if title == "Localbitcoins" {
            if let url = NSURL(string: "https://localbitcoins.com/?ch=cynk"){ if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
                
                } }
        }
        else if title == "Coinsecure" {
            if let url = NSURL(string: "https://coinsecure.in/signup/TVRWPVbGFVx7nYcr6YYM"){ if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
                } }
        }
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
}




