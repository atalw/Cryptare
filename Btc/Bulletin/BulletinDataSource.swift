/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * A set of tools to interact with the demo data.
 *
 * This demonstrates how to create and configure bulletin items.
 */

enum BulletinDataSource {
    
    // MARK: - Pages
    
    /**
     * Create the introduction page.
     *
     * This creates a `FeedbackPageBulletinItem` with: a title, an image, a description text and
     * and action button.
     *
     * The action button presents the next item (the textfield page).
     */
    
    static func makeIntroPage() -> FeedbackPageBulletinItem {
        
        let page = FeedbackPageBulletinItem(title: "Add Portfolio")
//        page.image = #imageLiteral(resourceName: "RoundedIcon")
//        page.imageAccessibilityLabel = "😻"
        
        page.descriptionText = "Enter the amount of Bitcoin and the date of purchase"
        page.actionButtonTitle = "Add"
        
        page.isDismissable = true
        
        page.actionHandler = { item in
            item.displayNextItem()
        }
        
        page.nextItem = makeTextFieldPage()
        
        return page
        
    }
    
    /**
     * Create the textfield page.
     *
     * This creates a `TextFieldBulletinPage` with: a title, an error label and a textfield.
     *
     * The keyboard return button presents the next item (the notification page).
     */
    static func makeTextFieldPage() -> TextFieldBulletinPage {
        let page = TextFieldBulletinPage()

        page.dismissalHandler = { item in
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        }
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
    }
    
//    /// Whether user completed setup.
//    static var userDidCompleteSetup: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: "HelloPetUserDidCompleteSetup")
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "HelloPetUserDidCompleteSetup")
//        }
//    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    /**
     * The setup did complete.
     *
     * The user info dictionary is empty.
     */
    
    static let SetupDidComplete = Notification.Name("HelloPetSetupDidCompleteNotification")
    static let TextFieldEntered = Notification.Name("TextFieldEntered")

    
}

