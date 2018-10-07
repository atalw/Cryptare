//
//  AlertsIntroViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 02/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import UserNotifications

class AlertsIntroViewController: UIViewController, UIScrollViewDelegate {

  var baseController: UIViewController!
  var fromAppDelegate: Bool = false
  
  @IBOutlet weak var slideScrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var doneButton: UIButton! {
    didSet {
      doneButton.isEnabled = false
      doneButton.setBackgroundColor(color: UIColor.darkGray, forState: .disabled)
      doneButton.setTitleColor(UIColor.white, for: .normal)
      doneButton.setTitleColor(UIColor.lightGray, for: .disabled)
      doneButton.layer.cornerRadius = 5
      doneButton.clipsToBounds = true
    }
  }
  @IBOutlet weak var settingsLabel: UILabel! {
    didSet {
      settingsLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var skipButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    slideScrollView.delegate = self
    let slides = createSlides()
    setupSlideScrollView(slides: slides)
    
    pageControl.numberOfPages = slides.count
    pageControl.currentPage  = 0
    
    view.bringSubview(toFront: pageControl)
    view.bringSubview(toFront: skipButton)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    FirebaseService.shared.updateScreenName(screenName: "Alerts Tutorial", screenClass: "AlertsIntroViewController")

  }
  
  func createSlides() -> [UIView] {
    
    let AlertsView = IntroTemplateView()
//    AlertsView.updateData(image: UIImage(named: "alertsIntro")!, title: "Smart price alerts.", description: "Stop worrying about the price of your favourite crypto. Create price alerts in 2 steps and be notified immediately.")
    
    AlertsView.templateTitleLabel.text = "Smart price alerts."
    AlertsView.templateImage.image = UIImage(named: "alertsIntro")!
    AlertsView.templateDescriptionLabel.text = "Stop worrying about the price of your favourite crypto. Create price alerts in 2 steps and be notified immediately."
    
    let HowOneView = IntroTemplateView()
//    HowOneView.updateData(image: UIImage(named: "stepOneAlertsIntro")!, title: "Step 1", description: "Select the cryptocurrency and exchange whose price you want to track.")
    
    HowOneView.templateTitleLabel.text = "Step 1"
    HowOneView.templateImage.image = UIImage(named: "stepOneAlertsIntro")!
    HowOneView.templateDescriptionLabel.text = "Select the cryptocurrency and exchange whose price you want to track."
    
    let HowTwoView = IntroTemplateView()
//    HowTwoView.updateData(image: UIImage(named: "stepTwoAlertsIntro")!, title: "Step 2", description: "Set a threshold price above or below which you'll be notified. Then save. That's it!")
    
    HowTwoView.templateTitleLabel.text = "Step 2"
    HowTwoView.templateImage.image = UIImage(named: "stepTwoAlertsIntro")!
    HowTwoView.templateDescriptionLabel.text = "Set a threshold price above or below which you'll be notified. Then save. That's it!"
    
    let ActiveView = IntroTemplateView()
//    ActiveView.updateData(image: UIImage(named: "activateAlertsIntro")!, title: "Alert activation.", description: "You can also deactivate and reactivate alerts with the ease of a tap.")
    
    ActiveView.templateTitleLabel.text = "Alert activation."
    ActiveView.templateImage.image = UIImage(named: "activateAlertsIntro")!
    ActiveView.templateDescriptionLabel.text = "You can also deactivate and reactivate alerts with the ease of a tap."
    
    return [AlertsView, HowOneView, HowTwoView, ActiveView]
  }
  
  func setupSlideScrollView(slides: [UIView]) {
    slideScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    
    slideScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
    
    slideScrollView.isPagingEnabled = true
    
    for index in 0..<slides.count {
      slides[index].frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: view.frame.height)
      slideScrollView.addSubview(slides[index])
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
    pageControl.currentPage = Int(pageIndex)
    
    if pageControl.currentPage == pageControl.numberOfPages-1 {
      doneButton.isEnabled = true
    }
  }
  
  @IBAction func skipButtonTapped(_ sender: Any) {
    Defaults[.mainAlertsIntroComplete] = true
    self.dismiss(animated: true, completion: {
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {granted, error in
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
              guard settings.authorizationStatus == .authorized else { return }
              DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
              }
            }
        })
      } else {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
          appDelegate.registerForPushNotifications(application: UIApplication.shared)
        }
      }
    })
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
