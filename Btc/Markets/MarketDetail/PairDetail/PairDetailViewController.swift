//
//  PairDetailViewController.swift
//  Cryptare
//
//  Created by Akshit Talwar on 22/04/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import UIKit

class PairDetailViewController: UIViewController {
  
  var parentController: PairDetailContainerViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Details"
    
    self.view.theme_backgroundColor = GlobalPicker.tableGroupBackgroundColor
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
