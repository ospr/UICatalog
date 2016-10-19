//
//  PowerOffViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UIPlaygroundElements

public class PowerOffViewController: UIViewController {
    
    @IBOutlet weak var powerOffSliderView: ThumbSliderView!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var powerOffSlideViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelStackView: UIStackView!
    
    var originalBrightness: CGFloat?
    var initialBrightness = CGFloat(0)
    
    public required init() {
        super.init(nibName: String(describing: PowerOffViewController.self), bundle: Bundle(for: type(of: self)))
        
        title = "Power Off"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPowerOffSliderView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup views to be animated in when the view appears
        view.layoutIfNeeded()
        blurEffectView.effect = nil
        powerOffSliderView.alpha = 0
        cancelStackView.alpha = 0
        powerOffSlideViewTrailingConstraint.constant = powerOffSliderView.bounds.width / 2.0
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originalBrightness = UIScreen.main.brightness
        
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
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset screen brightness when leaving view
        if let originalBrightness = originalBrightness {
            UIScreen.main.brightness = originalBrightness
        }
    }
    
    // MARK: - Working with Power Off Slider
    
    private func setupPowerOffSliderView() {
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderDidTouchDown), for: [.touchDown])
        powerOffSliderView.addTarget(self, action: #selector(powerOffSliderValueDidChange), for: [.valueChanged])
    }
    
    func powerOffSliderValueDidChange() {
        dimmingView.alpha = CGFloat(powerOffSliderView.value)
        UIScreen.main.brightness = initialBrightness - (initialBrightness * CGFloat(powerOffSliderView.value))
    }
    
    func powerOffSliderDidTouchDown() {
        // If the slider value is 1, then reset the initial brightness to the original brightness
        // (the one we started with when the view was shown). This will allow the view to raise
        // the brightness back up as the slider resets back to a value of 0. Otherwise use the
        // screen's current brightness.
        initialBrightness = (powerOffSliderView.value == 1) ? (originalBrightness ?? 0) : UIScreen.main.brightness
    }
}
