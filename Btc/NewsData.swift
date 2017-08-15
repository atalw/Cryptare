//
//  NewsData.swift
//  Btc
//
//  Created by Akshit Talwar on 14/08/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Foundation

class NewsData: NSObject {
    let title: String
    let pubDate: Date
    let link: String
    
    init(title: String, pubDate: Date, link: String) {
        self.title = title
        self.pubDate = pubDate
        self.link = link
    }
}
