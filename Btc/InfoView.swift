//
//  InfoView.swift
//  Btc
//
//  Created by Akshit Talwar on 11/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
    // Our custom view from the XIB file
    @IBOutlet var view: UIView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
     Loads a view instance from the xib file
     
     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
//        let dynamicMetatype = UIView.self
//        let bundle = Bundle(for: dynamicMetatype)
//        let nib = UINib(nibName: "InfoView", bundle: bundle)
//        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? UIView else {
//            fatalError("Could not load view from nib file")
//        }
        
        let view = Bundle.main.loadNibNamed("InfoView", owner: self, options: nil) as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
     func setupView() {
//        view = loadViewFromXibFile()
        Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)
        view.frame = self.bounds
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
//        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
//        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
//        onView.needsUpdateConstraints()
        
        // display the view
//        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
//            self.transform = CGAffineTransformIdentity
        })
        
    }

}
