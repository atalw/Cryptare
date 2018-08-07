//
//  IntroViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 12/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class AppIntroViewController: UIViewController, UIScrollViewDelegate {
  
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
    FirebaseService.shared.updateScreenName(screenName: "Intro Onboard", screenClass: "AppIntroViewController")

  }
  
  func createSlides() -> [UIView] {
    
    let WelcomeView = Bundle.main.loadNibNamed("WelcomeView", owner: self, options: nil)?.first as! UIView
    
    let PortfolioView = IntroTemplateView()
    PortfolioView.updateData(image: UIImage(named: "portfolioIntro")!, title: "Easy portfolio management.", description: "Stop calculating your profits on paper and let Cryptare do the work for you.")
    
    let MarketsView = IntroTemplateView()
    MarketsView.updateData(image: UIImage(named: "marketsIntro")!, title: "Save upto 20% on each purchase.", description: "Make wise financial decisions by comparing the prices of cryptocurrencies on 100+ different exchanges.")
    
    let DashboardView = IntroTemplateView()
    DashboardView.updateData(image: UIImage(named: "dashboardIntro")!, title: "Real-time market data.", description: "View the global data of 500+ Cryptocurrencies updated every minute in 15+ different currencies.")
   
    
    let NewsView = IntroTemplateView()
    NewsView.updateData(image: UIImage(named: "newsIntro")!, title: "News for each cryptocurrency.", description: "In such a fast-paced market, stay ahead of the curve with aggregated news for each cryptocurrency.")
    
    return [WelcomeView, PortfolioView, MarketsView, DashboardView, NewsView]
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
    
    Defaults[.mainAppIntroComplete] = true
    self.dismiss(animated: true, completion: {
      if self.fromAppDelegate && self.baseController != nil {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let countrySelectionViewController = storyboard.instantiateViewController(withIdentifier: "CountrySelectionViewController") as! CountrySelectionViewController
        
        self.baseController.present(countrySelectionViewController, animated: true, completion: nil)
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
