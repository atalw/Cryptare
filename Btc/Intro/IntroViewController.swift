//
//  IntroViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 12/03/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class IntroViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var slideScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
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

    func createSlides() -> [UIView] {
        let slideOne = Bundle.main.loadNibNamed("FirstView", owner: self, options: nil)?.first as! UIView
        let slideTwo = Bundle.main.loadNibNamed("SecondView", owner: self, options: nil)?.first as! UIView
        let slideThree = Bundle.main.loadNibNamed("ThirdView", owner: self, options: nil)?.first as! UIView
        
        return [slideOne, slideTwo, slideThree]
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
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        Defaults[.mainIntroComplete] = true
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
