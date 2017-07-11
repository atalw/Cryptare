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
        return items
    }
    
    func updateItems(_ element: String, index: Int) {
        items[index] = element
    }
    
    func empty() {
        print("here")
        print(items)
        items.removeAll(keepingCapacity: false)
        print(items)
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
        cell.myButton.setTitleColor(UIColor.white, for: .normal)
        cell.myButton.backgroundColor = hexStringToUIColor(hex: "#3498db")

//        cell.myButton.backgroundColor = nil
        
        if item == "Zebpay" || item == "Unocoin" || item == "Localbitcoins" || item == "Coinsecure" {
            cell.myButton.isEnabled = true
            //            cell.myButton.setTitleColor(UIColor.blue, for: .normal)
            cell.myButton.setTitleColor(UIColor.white, for: .normal)
            cell.myButton.backgroundColor = hexStringToUIColor(hex: "#2980b9")
            cell.myButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//            cell.myButton.layer.cornerRadius = 8
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
            
//            headerView.siteLabel.layer.addBorder(edge: UIRectEdge.right, color: hexStringToUIColor(hex: "#d35400"), thickness: 2)
//            headerView.buyLabel.layer.addBorder(edge: UIRectEdge.right, color: hexStringToUIColor(hex: "#d35400"), thickness: 2)
            
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

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}



