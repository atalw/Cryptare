//
//  SortDropDownViews.swift
//  Btc
//
//  Created by Akshit Talwar on 18/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import YNDropDownMenu


class DateDropDownView: YNDropDownView {
    
    @IBOutlet weak var dateSegmentControl: UISegmentedControl!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print("done")
        self.changeMenu(title: "Date", status: .selected, at: 1)
        self.hideMenu()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.hideMenu()
    }
    
    override func dropDownViewOpened() {
        print("dropDownViewOpened")
        
    }
    
    override func dropDownViewClosed() {
        print("dropDownViewClosed")
    }
}

