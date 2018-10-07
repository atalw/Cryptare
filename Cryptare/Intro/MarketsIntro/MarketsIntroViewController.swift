//
//  MarketsIntroViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 02/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class MarketsIntroViewController: UIViewController, UIScrollViewDelegate {
  
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
    FirebaseService.shared.updateScreenName(screenName: "Markets Tutorial", screenClass: "MarketsIntroViewController")

  }
  
  func createSlides() -> [UIView] {
    
    let FavouritesView = IntroTemplateView()
//    FavouritesView.updateData(image: UIImage(named: "favouriteTradingPairsIntro")!, title: "Create a favourites list.", description: "Track your favourite trading-pairs and exchanges all in one place.")
    
    FavouritesView.templateTitleLabel.text = "Create a favourites list."
    FavouritesView.templateImage.image = UIImage(named: "favouriteTradingPairsIntro")!
    FavouritesView.templateDescriptionLabel.text = "Track your favourite trading-pairs and exchanges all in one place."
    
    let Markets = IntroTemplateView()
//    Markets.updateData(image: UIImage(named: "marketDetailsIntro")!, title: "Detailed market information.", description: "Access details of every market including all supported trading-pairs.")
    
    Markets.templateTitleLabel.text = "Detailed market information."
    Markets.templateImage.image = UIImage(named: "marketDetailsIntro")!
    Markets.templateDescriptionLabel.text = "Track your favourite trading-pairs and exchanges all in one place."
    
    let AlertsView = IntroTemplateView()
//    AlertsView.updateData(image: UIImage(named: "marketAlertsIntro")!, title: "Smart trade-pair alerts.", description: "Create market trade-pair alerts easily to track the price on that specific exchange.")
    
    AlertsView.templateTitleLabel.text = "Smart trade-pair alerts."
    AlertsView.templateImage.image = UIImage(named: "marketAlertsIntro")!
    AlertsView.templateDescriptionLabel.text = "Create market trade-pair alerts easily to track the price on that specific exchange."
    
    return [FavouritesView, Markets, AlertsView]
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
    Defaults[.mainMarketsIntroComplete] = true
    self.dismiss(animated: true, completion: nil)
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
