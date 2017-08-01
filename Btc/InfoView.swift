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
//        view.frame = UIScreen.main.bounds
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
//        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    @IBAction func dismissInfoView(_ sender: Any) {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            self.isHidden = true
        }, completion: nil)
    }
}
