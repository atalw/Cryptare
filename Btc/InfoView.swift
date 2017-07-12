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
    //    @IBOutlet weak var closeButton: UIButton!
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
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
        Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func displayView(overlayView: UIView) {
        self.alpha = 0.0
        overlayView.addSubview(self)
        
        // display the view
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
        })
    }
    
    @IBAction func dismissInfoView(_ sender: Any) {
        self.isHidden = true
    }
}
