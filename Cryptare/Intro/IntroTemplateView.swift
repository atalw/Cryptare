//
//  IntroTemplateView.swift
//  Cryptare
//
//  Created by Akshit Talwar on 01/05/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class IntroTemplateView: UIView {

  @IBOutlet var contentView: UIView!
  @IBOutlet weak var templateImage: UIImageView!
  @IBOutlet weak var templateTitleLabel: UILabel! {
    didSet {
      templateTitleLabel.adjustsFontSizeToFitWidth = true
    }
  }
  @IBOutlet weak var templateDescriptionLabel: UILabel! {
    didSet {
      templateDescriptionLabel.adjustsFontSizeToFitWidth = true
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  convenience init() {
    self.init(frame: .zero)
  }
  
  private func commonInit() {
//    Bundle.main.loadNibNamed("IntroTemplate", owner: self, options: nil)
    contentView = loadNib()
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(contentView)
    
//    contentView.frame = self.bounds
//    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
  
  /** Loads instance from nib with the same name. */
  func loadNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nibName = "IntroTemplate"
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as! UIView
  }
  
//  func updateData(image: UIImage, title: String, description: String) {
//    if templateImage != nil {
//      templateImage.image = image
//    }
//
//    if templateTitleLabel != nil {
//      templateTitleLabel.text = title
//    }
//
//    if templateDescriptionLabel != nil {
//      templateDescriptionLabel.text = description
//    }
//  }
  
  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
