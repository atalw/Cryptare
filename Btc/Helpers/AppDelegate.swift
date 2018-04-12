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
import GoogleMobileAds
import SwiftyStoreKit
import Armchair
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var ref: DatabaseReference!
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        // armchair
        Armchair.appID("1266256984")
        Armchair.significantEventsUntilPrompt(5)
        
        // navigation bar
        UINavigationBar.appearance().barTintColor = UIColor.init(hex: "46637F")
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().theme_barTintColor = GlobalPicker.navigationBarTintColor
        
//        // apple receipt validation
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
//        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
//            switch result {
//            case .success(let receipt):
//                print("Verify receipt success: \(receipt)")
//                if let originalAppVersion = receipt["receipt"]?["original_application_version"] as? String {
//                    print(originalAppVersion, "Original")
//                    if let versionNumber = Double(originalAppVersion) {
//                        if versionNumber < 2.92 {
//                            Defaults[.removeAdsPurchased] = true
//                            Defaults[.previousPaidUser] = true
//                        }
//                    }
//                }
//            case .error(let error):
//                print("Verify receipt failed: \(error)")
//            }
//        }
        
        // google ads
        GADMobileAds.configure(withApplicationID: "ca-app-pub-5797975753570133~4584171807")
        
        
        
        // storyboard
        #if PRO_VERSION
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        #endif
        
        #if LITE_VERSION
            let storyboard = UIStoryboard(name: "MainLite", bundle: nil)
        #endif
        
        // dashboard settings
        if !Defaults.hasKey(.dashboardFavourites) &&
            !Defaults.hasKey(.dashboardFavouritesFirstTab) {
            Defaults[.dashboardFavourites] = ["BTC", "ETH", "LTC", "XRB"]
            Defaults[.dashboardFavouritesFirstTab] = true
        }
        
        // chart settings
        if !Defaults.hasKey(.chartSettingsExist) {
            Defaults[.chartMode] = "smooth"
            
            Defaults[.xAxis] = ChartSettingsDefault.xAxis
            Defaults[.xAxisGridLinesEnabled] = ChartSettingsDefault.xAxisGridLinesEnabled

            Defaults[.yAxis] = ChartSettingsDefault.yAxis
            Defaults[.yAxisGridLinesEnabled] = ChartSettingsDefault.yAxisGridLinesEnabled

            Defaults[.chartSettingsExist] = true
        }
        
        // market settings
        if !Defaults.hasKey(.marketSettingsExist) {
            Defaults[.marketSort] = "buy"
            Defaults[.marketOrder] = "ascending"
            
            Defaults[.marketSettingsExist] = true
        }
        
        // news settings
        
        if !Defaults.hasKey(.newsSettingsExist) {
            Defaults[.newsSort] = "popularity"
            
            Defaults[.newsSettingsExist] = true
        }
        
        let selectedCountry = Defaults[.selectedCountry]
        let introComplete = Defaults[.mainAppIntroComplete]
        
        // if country has been selected
        if selectedCountry != "" {
            
            for countryTuple in GlobalValues.countryList {
                if selectedCountry == countryTuple.0 {
                    GlobalValues.currency = countryTuple.1
                }
            }
            
            self.createMenuView(storyboard: storyboard)

            if !introComplete {
                let introViewController = storyboard.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
                
                self.window?.rootViewController?.present(introViewController, animated: true, completion: nil)
            }
        }
        else { // country not selected
            if introComplete {
                
                GlobalValues.currency = "USD"
                
                self.createMenuView(storyboard: storyboard)
                
                 let countrySelectionViewController = storyboard.instantiateViewController(withIdentifier: "CountrySelectionViewController") as! CountrySelectionViewController
                
                self.window?.rootViewController?.present(countrySelectionViewController, animated: true, completion: nil)
            }
            else {
                GlobalValues.currency = "USD"
                
                self.createMenuView(storyboard: storyboard)
                
                let introViewController = storyboard.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
                introViewController.baseController = self.window?.rootViewController
                introViewController.fromAppDelegate = true
                
                self.window?.rootViewController?.present(introViewController, animated: true, completion: nil)
                
            }
        }
        
        // notification request
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (isGranted, error) in
                if error != nil { return }
                
                if isGranted {
                    UNUserNotificationCenter.current().delegate = self
                    Messaging.messaging().delegate = self
                }
            })
            application.registerForRemoteNotifications()
            
            setUpFirebase()
            
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }
    
    func createMenuView(storyboard: UIStoryboard) {
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        leftViewController.mainViewController = nvc
        
        SlideMenuOptions.contentViewDrag = true
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.animationDuration = 0.2
        SlideMenuOptions.contentViewOpacity = 0.1
        SlideMenuOptions.leftViewWidth = 220
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        self.window?.rootViewController = slideMenuController
        slideMenuController.delegate = mainViewController as SlideMenuControllerDelegate
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
        
        Database.database().reference().child("all_exchange_info").observeSingleEvent(of: .value, with: { snapshot -> Void in
            if let dict = snapshot.value as? [String: [String: String]] {
                marketInformation = dict
            }
        })
    }
    
    func setUpFirebaseLite() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
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

