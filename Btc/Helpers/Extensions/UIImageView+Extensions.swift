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
        if let savedImage = UIImage(data: imageData) {
          self.image = savedImage
          return
        }
      }
      
    }
    
    if let image = UIImage(named: coin.lowercased()) {
      image.saveImage(coin: coin)
      return
    }
    else {
      let url = URL(string: urlString)
      
      URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        if error != nil {
          print(error ?? "image fetch error")
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
    }
    
    self.image = UIImage(named: "generic.png")
  }
  
 
  
  func loadSavedImage(coin: String) {
    var cryptoIconsDict = Defaults[.cryptoIcons]
    
    if cryptoIconsDict[coin] != nil {
      if let imageData = cryptoIconsDict[coin] as? Data {
        if let savedImage = UIImage(data: imageData) {
          self.image = savedImage
          return
        }
      }
      
    }
    else {
      if let image = UIImage(named: coin.lowercased()) {
        image.saveImage(coin: coin)
        self.image = image
        return
      }
    }
    
    self.image = UIImage(named: "generic.png")
  }
}
