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

//extension BtcPrices: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let item = items[indexPath.row]
//        
//        cell.textLabel!.text = item
//        
//        return cell
//    }
//}

extension BtcPrices: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! MyCollectionViewCell
        let item = items[indexPath.item]
        cell.myLabel.text = item

//        if (cell.myLabel != nil) {
//            cell.myLabel.text = item
//            print(item)
//        }
//
        
        
//        cell.textLabel!.text = item
//        print(item)
//        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionViewHeader
//            headerView.label.text = searches[(indexPath as NSIndexPath).section.searchTerm
            headerView.siteLabel.text = "Site"
            headerView.buyLabel.text = "Buy"
            headerView.sellLabel.text = "Sell"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}
