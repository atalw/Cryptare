//
//  AppDelegate.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if #available(iOS 10.0, *) {
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (isGranted, error) in
                    if error != nil {
                        // error
                    }
                    else {
                        UNUserNotificationCenter.current().delegate = self
                        Messaging.messaging().delegate = self
                    }
                })
                application.registerForRemoteNotifications()
                FirebaseApp.configure()
                ref = Database.database().reference()

            } else {
                // Fallback on earlier versions
            }
        #endif
    
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        
        if UserDefaults.standard.string(forKey: "selectedCountry") != nil {
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            window?.rootViewController = rootViewController
        }

        return true
    }
    
    func connectToFCM() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    func disconnectFromFCM() {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        disconnectFromFCM()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        FirstViewController.loadData(<#T##FirstViewController#>)
        connectToFCM()
        
        let fcmToken = Messaging.messaging().fcmToken
        
        //Retrieve lists of items or listen for additions to a list of items.
        //This event is triggered once for each existing child and then again every time a new child is added to the specified path.
        //The listener is passed a snapshot containing the new child's data.
        ref.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            let enumerator = snapshot.children
            
            while let child = enumerator.nextObject() as? DataSnapshot {
                if child.value as? String == fcmToken {
                    print("exists")
                    return;
                }
            }
            print("here")
            let newChild = self.ref.child("user_ids").childByAutoId()
            newChild.setValue(Messaging.messaging().fcmToken)

        })
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
//        let newToken = InstanceID.instanceID().token()
        connectToFCM()
    }

}

