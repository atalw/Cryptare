//
//  UIImageView+Extensions.swift
//  Cryptare
//
//  Created by Akshit Talwar on 05/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension UIImageView {
    
    func loadSavedImageWithURL(coin: String, urlString: String) {
        var cryptoIconsDict = Defaults[.cryptoIcons]
        
        if cryptoIconsDict[coin] != nil {
            if let imageData = cryptoIconsDict[coin] as? Data {
                if let savedImage = UIImage(data: imageData) as? UIImage {
                    self.image = savedImage
                    return
                }
            }
            
        }
        
        let url = URL(string: urlString)

        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    let imageData = UIImagePNGRepresentation(downloadedImage)
                    Defaults[.cryptoIcons][coin] = imageData
                    
                    self.image = downloadedImage
                    return
                }
            }
        }).resume()
        
        self.image = UIImage(named: "generic.png")
    }
    
    func loadSavedImage(coin: String) {
        var cryptoIconsDict = Defaults[.cryptoIcons]
        
        if cryptoIconsDict[coin] != nil {
            if let imageData = cryptoIconsDict[coin] as? Data {
                if let savedImage = UIImage(data: imageData) as? UIImage {
                    self.image = savedImage
                    return
                }
            }
            
        }
        
        self.image = UIImage(named: "generic.png")
    }
}
