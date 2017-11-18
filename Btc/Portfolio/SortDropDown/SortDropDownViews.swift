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
    override func dropDownViewOpened() {
        print("dropDownViewOpened")
    }
    
    override func dropDownViewClosed() {
        print("dropDownViewClosed")
    }
}

