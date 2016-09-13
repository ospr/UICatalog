//
//  PowerOffViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UIPlaygroundElements

class PowerOffViewController: UIViewController {
    
    @IBOutlet weak var powerOffSliderView: ThumbSliderView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var powerOffSlideViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelStackView: UIStackView!
    
    var initialBrightness = CGFloat(0)
    
    required init() {
        super.init(nibName: String(describing: PowerOffViewController.self), bundle: nil)
        
        title = "Power Off"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPowerOffSliderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup views to be animated in when the view appears
        blurEffectView.effect = nil
        powerOffSliderView.alpha = 0
        cancelStackView.alpha = 0
        powerOffSlideViewTrailingConstraint.constant = powerOffSliderView.bounds.width / 2.0
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate in the views
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6, animations: { 
                self.blurEffectView.effect = UIBlurEffect(style: .dark)
                self.powerOffSliderView.alpha = 1
                self.cancelStackView.alpha = 1
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8, animations: { 
                self.powerOffSlideViewTrailingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }, completion: nil)
    }
    
    // MARK: - Working with Power Off Slider
    
    func setupPowerOffSliderView() {
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderDidTouchDown), for: [.touchDown])
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderValueDidChange), for: [.valueChanged])
    }
    
    func powerOffSliderValueDidChange() {
        dimmingView.alpha = CGFloat(powerOffSliderView.value)
        UIScreen.main.brightness = initialBrightness - (initialBrightness * CGFloat(powerOffSliderView.value))
    }
    
    func powerOffSliderDidTouchDown() {
        initialBrightness = UIScreen.main.brightness
    }
}
