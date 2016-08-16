//
//  PowerOffViewViewController.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UICatalogElements

// TODO: fix name here
class PowerOffViewViewController: UIViewController {
    
    @IBOutlet weak var powerOffSliderView: ThumbSliderView!
    @IBOutlet weak var dimmingView: UIView!
    
    var initialBrightness = CGFloat(0)
    
    required init() {
        super.init(nibName: String(PowerOffViewViewController.self), bundle: nil)
        
        title = "Power Off"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPowerOffSliderView()
    }
    
    // MARK: - Working with Power Off Slider
    
    func setupPowerOffSliderView() {
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderDidTouchDown), forControlEvents: [.TouchDown])
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderValueDidChange), forControlEvents: [.ValueChanged])
    }
    
    func powerOffSliderValueDidChange() {
        dimmingView.alpha = CGFloat(powerOffSliderView.value)
        UIScreen.mainScreen().brightness = initialBrightness - (initialBrightness * CGFloat(powerOffSliderView.value))
    }
    
    func powerOffSliderDidTouchDown() {
        initialBrightness = UIScreen.mainScreen().brightness
    }
}
