//
//  ThumbSliderView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

@IBDesignable
public class ThumbSliderView: UIControl {
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var vibrancyBackgroundView: UIView!
    @IBOutlet public private(set) weak var thumbView: UIImageView!
    @IBOutlet private weak var informationalLabel: UILabel!
    @IBOutlet private weak var backgroundInformationalLabel: UILabel!
    @IBOutlet private weak var backgroundLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var thumbViewTopPaddingConstraint: NSLayoutConstraint!
    
    public var value: Double = 0 {
        didSet {
            let previousValue = min(1, max(0, oldValue))
            guard previousValue != value else {
                return
            }
            
            backgroundLeadingConstraint.constant = maxBackgroundLeadingConstraintConstant() * CGFloat(value)
            sendActionsForControlEvents([.ValueChanged])
            updatePowerOffLabel()
        }
    }
    
    @IBInspectable var thumbViewImage: UIImage? {
        get { return thumbView.image }
        set { thumbView.image = newValue }
    }
    
    @IBInspectable var informationalText: String? {
        get { return informationalLabel.text }
        set {
            informationalLabel.text = newValue
            backgroundInformationalLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let view = addOwnedViewFrom(nibNamed: String(ThumbSliderView.self))
        view.backgroundColor = .clearColor()
        
        setupThumbView()
        setupInformationalLabel()
    }
    
    private func setupThumbView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(thumbViewWasPanned))
        thumbView.addGestureRecognizer(panGesture)
        panGesture.enabled = true
    }
    
    private func setupInformationalLabel() {
        // Create a mask for the white informational label to glide through
        // the label to create a shimmer effect
        let shimmerMaskImage = UIImage(named: "ShimmerMask", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)!
        let shimmerMaskLayer = CALayer()
        shimmerMaskLayer.contents = shimmerMaskImage.CGImage
        shimmerMaskLayer.contentsGravity = kCAGravityCenter
        shimmerMaskLayer.frame = CGRect(x: -shimmerMaskImage.size.width, y: shimmerMaskImage.size.height / 2.0,
                                        width: shimmerMaskImage.size.width, height: shimmerMaskImage.size.height)
        
        // Create the horizontal animation to move the shimmer mask
        let shimmerAnimation = CABasicAnimation(keyPath: "position.x")
        shimmerAnimation.byValue = informationalLabel.bounds.size.width
        shimmerAnimation.repeatCount = HUGE
        shimmerAnimation.duration = 3.5
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shimmerMaskLayer.addAnimation(shimmerAnimation, forKey: "shimmerAnimation")
        
        informationalLabel.layer.mask = shimmerMaskLayer
    }

    // MARK: - View Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        vibrancyBackgroundView.layer.cornerRadius = vibrancyBackgroundView.bounds.size.height / 2.0
        thumbView.roundCornersToFormCircle()
    }
    
    func maxBackgroundLeadingConstraintConstant() -> CGFloat {
        let thumbViewPadding = thumbViewTopPaddingConstraint.constant
        return backgroundView.superview!.bounds.width - (thumbViewPadding * 2 + thumbView.frame.width)
    }
    
    // MARK: - Working with slider value
    
    func updateValue() {
        let currentValue = max(0.0, min(1.0, Double(backgroundLeadingConstraint.constant / maxBackgroundLeadingConstraintConstant())))
        
        if value != currentValue {
            value = currentValue
            sendActionsForControlEvents([.ValueChanged])
        }
    }
    
    func updatePowerOffLabel() {
        // Hide the power off label when the slider is panned
        let desiredPowerOffLabelAlpha: CGFloat = (value == 0) ? 1.0 : 0.0
        if self.informationalLabel.alpha != desiredPowerOffLabelAlpha {
            UIView.animateWithDuration(0.10, animations: {
                self.informationalLabel.alpha = desiredPowerOffLabelAlpha
                self.backgroundInformationalLabel.alpha = desiredPowerOffLabelAlpha
            })
        }
    }
    
    // MARK: - Gesture Handling
    
    func thumbViewWasPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Possible, .Began:
            break
            
        case .Changed:
            // Update the leading constraint to move the slider to match
            // the user's pan gesture
            let translation = recognizer.translationInView(self)
            backgroundLeadingConstraint.constant = max(translation.x, 0)
            updateValue()
            
        case .Ended, .Cancelled, .Failed:
            // Determine whether the user slid the slider far enough to
            // either have the slider finish to the end position or slide
            // back to the start position
            let startValue = value
            let shouldSlideToEnd = startValue > 0.5
            
            DisplayLinkProgressor.run(withDuration: 0.10, update: { (progress) in
                let finalValue = shouldSlideToEnd ? 1.0 : 0.0
                let nextValue = startValue + progress * (finalValue - startValue)
                
                self.value = nextValue
            })
        }
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        sendActionsForControlEvents([.TouchDown])
    }
}
