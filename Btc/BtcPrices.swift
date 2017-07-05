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

}

extension BtcPrices: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! MyCollectionViewCell
        let item = items[indexPath.item]
        cell.myButton.setTitle(item, for: .normal)
        cell.myButton.isEnabled = false
        cell.myButton.setTitleColor(UIColor.black, for: .normal)

        if item == "Zebpay" || item == "Unocoin" || item == "Localbitcoins" || item == "Coinsecure" {
            cell.myButton.isEnabled = true
            cell.myButton.setTitleColor(UIColor.blue, for: .normal)
            cell.myButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
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
            if let url = NSURL(string: "https://www.zebpay.com/?utm_campaign=app_refferal_ref/ref/REF34005162&utm_medium=app&utm_source=zebpay_app_refferal"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }

        }
        else if title == "Unocoin" {
            if let url = NSURL(string: "https://www.unocoin.com/"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
        }
        else if title == "Localbitcoins" {
            if let url = NSURL(string: "https://localbitcoins.com/?ch=cynk"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
        }
        else if title == "Coinsecure" {
            if let url = NSURL(string: "https://coinsecure.in/signup/TVRWPVbGFVx7nYcr6YYM"){ UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) }
        }
    }
}




