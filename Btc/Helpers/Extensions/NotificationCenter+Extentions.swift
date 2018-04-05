//
//  NotificationCenter+Extentions.swift
//  Btc
//
//  Created by Akshit Talwar on 27/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation


// MARK: - Notifications

extension Notification.Name {
    
    /**
     * The setup did complete.
     *
     * The user info dictionary is empty.
     */
    
//    static let TextFieldEntered = Notification.Name("TextFieldEntered")
    
    static let transactionAdded = Notification.Name("transactionAdded")
}
