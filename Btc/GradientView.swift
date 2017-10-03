//
//  GradientView.swift
//  Btc
//
//  Created by Akshit Talwar on 03/10/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    var colourOne: UIColor!, colourTwo: UIColor!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [colourOne.cgColor, colourTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.cornerRadius = 10
        
        gradientLayer.masksToBounds = false
        gradientLayer.shadowColor = UIColor.black.cgColor
        gradientLayer.shadowOpacity = 0.2
        gradientLayer.shadowOffset = CGSize(width: 1, height: 1)
    }

}
