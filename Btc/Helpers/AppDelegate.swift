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
import SlideMenuControllerSwift
import Charts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (isGranted, error) in
                if error != nil {}
                else {
                    UNUserNotificationCenter.current().delegate = self
                    Messaging.messaging().delegate = self
                }
            })
            application.registerForRemoteNotifications()

            #if PRO_VERSION
                setUpFirebase()
            #endif
            #if LITE_VERSION
                setUpFirebaseLite()
            #endif
        } else {
            // Fallback on earlier versions
        }
        
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        #endif
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        
        // chart settings
        if !defaults.bool(forKey: "chartSettingsExist") {
            defaults.set("smooth", forKey: "chartMode")
            
            defaults.set(ChartSettingsDefault.xAxis, forKey: "xAxis")
            defaults.set(ChartSettingsDefault.xAxisGridLinesEnabled, forKey: "xAxisGridLinesEnabled")

            defaults.set(ChartSettingsDefault.yAxis, forKey: "yAxis")
            defaults.set(ChartSettingsDefault.yAxisGridLinesEnabled, forKey: "yAxisGridLinesEnabled")
            
            defaults.set(true, forKey: "chartSettingsExist")
        }
     
        // market settings
        if !defaults.bool(forKey: "marketSettingsExist") {
            defaults.set("buy", forKey: "marketSort")
            defaults.set("ascending", forKey: "marketOrder")
            
            defaults.set(true, forKey: "marketSettingsExist")
        }
        
        // news settings
        if !defaults.bool(forKey: "newsSettingsExist") {
            defaults.set("popularity", forKey: "newsSort")
            
            defaults.set(true, forKey: "newsSettingsExist")
        }
        
        if defaults.string(forKey: "selectedCountry") != nil {
            if defaults.string(forKey: "selectedCountry") == "india" {
                GlobalValues.currency = "INR"
            }
            else if defaults.string(forKey: "selectedCountry") == "usa" {
                GlobalValues.currency = "USD"
            }
            else if defaults.string(forKey: "selectedCountry") == "eu" {
                GlobalValues.currency = "EUR"
            }
            self.createMenuView(storyboard: storyboard)
        }
        
        return true
    }
    
    func createMenuView(storyboard: UIStoryboard) {
        let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: dashboardViewController)
        
        leftViewController.dashboardViewController = nvc
        
        SlideMenuOptions.contentViewDrag = true
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.animationDuration = 0.2
        SlideMenuOptions.contentViewOpacity = 0.1
        SlideMenuOptions.leftViewWidth = 220
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        self.window?.rootViewController = slideMenuController
        slideMenuController.delegate = dashboardViewController as SlideMenuControllerDelegate
        self.window?.makeKeyAndVisible()
    }
    
    func setUpFirebase() {
        FirebaseApp.configure()
        ref = Database.database().reference().child("user_ids")
        
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
            let newChild = self.ref.child("users").childByAutoId()
            newChild.setValue(Messaging.messaging().fcmToken)
        })
    }
    
    func setUpFirebaseLite() {
        print("here")
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        print("here2")
        ref = Database.database().reference().child("user_ids_lite")
        
        let fcmToken = Messaging.messaging().fcmToken
        print(fcmToken)
        
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
            let newChild = self.ref.child("users").childByAutoId()
            newChild.setValue(Messaging.messaging().fcmToken)
        })
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
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        connectToFCM()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("registered")
        Messaging.messaging().subscribe(toTopic: "/topics/general")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    }
    
    @available(iOS 10.0, *)
    // display notification even if in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

}

