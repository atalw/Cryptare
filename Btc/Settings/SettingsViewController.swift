//
//  SettingsViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 08/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var xAxisSwitch: UISwitch!
    @IBOutlet weak var xAxisGridLinesSwitch: UISwitch!

    @IBOutlet weak var yAxisSwitch: UISwitch!
    @IBOutlet weak var yAxisGridLinesSwitch: UISwitch!
    
    @IBOutlet weak var linearModeButton: UIButton!
    @IBOutlet weak var smoothModeButton: UIButton!
    @IBOutlet weak var steppedModeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        linearModeButton.layer.cornerRadius = 5
        smoothModeButton.layer.cornerRadius = 5
        steppedModeButton.layer.cornerRadius = 5
        
        linearModeButton.setTitleColor(UIColor.black, for: .normal)
        smoothModeButton.setTitleColor(UIColor.black, for: .normal)
        steppedModeButton.setTitleColor(UIColor.black, for: .normal)
        
        linearModeButton.setTitleColor(UIColor.white, for: .selected)
        smoothModeButton.setTitleColor(UIColor.white, for: .selected)
        steppedModeButton.setTitleColor(UIColor.white, for: .selected)
        
        xAxisSwitch.addTarget(self, action: #selector(xAxisChange), for: .valueChanged)
        xAxisGridLinesSwitch.addTarget(self, action: #selector(xAxisGridLinesChange), for: .valueChanged)

        yAxisSwitch.addTarget(self, action: #selector(yAxisChange), for: .valueChanged)
        yAxisGridLinesSwitch.addTarget(self, action: #selector(yAxisGridLinesChange), for: .valueChanged)
        
        loadChartSettings()
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)

    }
    
    @objc func xAxisChange(xAxisSwitch: UISwitch) {
        let state = xAxisSwitch.isOn
        if state {
            ChartSettings.xAxis = true
            xAxisGridLinesSwitch.isEnabled = true
        }
        else {
            ChartSettings.xAxis = false
            xAxisGridLinesSwitch.isEnabled = false
        }
    }
    
    @objc func xAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = xAxisGridLinesSwitch.isOn
        if state {
            ChartSettings.xAxisGridLinesEnabled = true
        }
        else {
            ChartSettings.xAxisGridLinesEnabled = false
        }
    }
    
    @objc func yAxisChange(xAxisSwitch: UISwitch) {
        let state = yAxisSwitch.isOn
        if state {
            ChartSettings.yAxis = true
            yAxisGridLinesSwitch.isEnabled = true
        }
        else {
            ChartSettings.yAxis = false
            yAxisGridLinesSwitch.isEnabled = false
        }
    }
    
    @objc func yAxisGridLinesChange(xAxisSwitch: UISwitch) {
        let state = yAxisGridLinesSwitch.isOn
        if state {
            ChartSettings.yAxisGridLinesEnabled = true
        }
        else {
            ChartSettings.yAxisGridLinesEnabled = false
        }
    }

    @IBAction func linearButtonTapped(_ sender: Any) {
        linearSelected()
        ChartSettings.chartMode = .linear
    }
    
    @IBAction func smoothButtonTapped(_ sender: Any) {
        smoothSelected()
        ChartSettings.chartMode = .cubicBezier
    }
    
    @IBAction func steppedButtonTapped(_ sender: Any) {
        steppedSelected()
        ChartSettings.chartMode = .stepped
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func linearSelected() {
        linearModeButton.isSelected = true
        smoothModeButton.isSelected = false
        steppedModeButton.isSelected = false
        
        linearModeButton.backgroundColor = UIColor.lightGray
        smoothModeButton.backgroundColor = UIColor.white
        steppedModeButton.backgroundColor = UIColor.white
    }
    
    func smoothSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = true
        steppedModeButton.isSelected = false
        
        linearModeButton.backgroundColor = UIColor.white
        smoothModeButton.backgroundColor = UIColor.lightGray
        steppedModeButton.backgroundColor = UIColor.white
        
    }
    
    func steppedSelected() {
        linearModeButton.isSelected = false
        smoothModeButton.isSelected = false
        steppedModeButton.isSelected = true
        
        linearModeButton.backgroundColor = UIColor.white
        smoothModeButton.backgroundColor = UIColor.white
        steppedModeButton.backgroundColor = UIColor.lightGray
    }

    @IBAction func chartResetDefaults(_ sender: Any) {
        ChartSettings.chartMode = ChartSettingsDefault.chartMode
        
        ChartSettings.xAxis = ChartSettingsDefault.xAxis
        ChartSettings.xAxisGridLinesEnabled = ChartSettingsDefault.xAxisGridLinesEnabled
        
        ChartSettings.yAxis = ChartSettingsDefault.yAxis
        ChartSettings.yAxisGridLinesEnabled = ChartSettingsDefault.yAxisGridLinesEnabled
        
        loadChartSettings()
    }
    
    func loadChartSettings() {
        // chart mode
        if ChartSettings.chartMode == .linear {
            linearSelected()
        }
        else if ChartSettings.chartMode == .cubicBezier {
            smoothSelected()
        }
        else if ChartSettings.chartMode == .stepped {
            steppedSelected()
        }
        
        // x-axis
        xAxisSwitch.setOn(ChartSettings.xAxis, animated: true)
        xAxisGridLinesSwitch.setOn(ChartSettings.xAxisGridLinesEnabled, animated: true)
        
        if !xAxisSwitch.isOn {
            xAxisGridLinesSwitch.isEnabled = false
        }
        
        // y-axis
        yAxisSwitch.setOn(ChartSettings.yAxis, animated: true)
        yAxisGridLinesSwitch.setOn(ChartSettings.yAxisGridLinesEnabled, animated: true)
        
        if !yAxisSwitch.isOn {
            yAxisGridLinesSwitch.isEnabled = false
        }
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
