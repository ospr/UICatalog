//
//  ThumbSliderView.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

@IBDesignable
open class ThumbSliderView: UIControl {
    
    @IBOutlet fileprivate weak var backgroundView: UIView!
    @IBOutlet fileprivate weak var vibrancyBackgroundView: UIView!
    @IBOutlet open fileprivate(set) weak var thumbView: UIImageView!
    @IBOutlet fileprivate weak var informationalLabel: UILabel!
    @IBOutlet fileprivate weak var backgroundInformationalLabel: UILabel!
    @IBOutlet fileprivate weak var backgroundLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var thumbViewTopPaddingConstraint: NSLayoutConstraint!
    
    open var value: Double = 0 {
        didSet {
            let previousValue = min(1, max(0, oldValue))
            guard previousValue != value else {
                return
            }
            
            backgroundLeadingConstraint.constant = maxBackgroundLeadingConstraintConstant() * CGFloat(value)
            sendActions(for: [.valueChanged])
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
    
    fileprivate func setup() {
        let view = addOwnedViewFrom(nibNamed: String(describing: ThumbSliderView.self))
        view.backgroundColor = .clear
        
        setupThumbView()
        setupInformationalLabel()
    }
    
    fileprivate func setupThumbView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(thumbViewWasPanned))
        thumbView.addGestureRecognizer(panGesture)
        panGesture.isEnabled = true
    }
    
    fileprivate func setupInformationalLabel() {
        // Create a mask for the white informational label to glide through
        // the label to create a shimmer effect
        let shimmerMaskImage = UIImage(named: "ShimmerMask", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let shimmerMaskLayer = CALayer()
        let cgImage = shimmerMaskImage.cgImage!
        shimmerMaskLayer.contents = cgImage
        shimmerMaskLayer.contentsGravity = kCAGravityCenter
        shimmerMaskLayer.frame.size = CGSize(width: cgImage.width, height: cgImage.height)
        
        informationalLabel.layer.mask = shimmerMaskLayer
    }

    // MARK: - View Layout
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        vibrancyBackgroundView.layer.cornerRadius = vibrancyBackgroundView.bounds.size.height / 2.0
        thumbView.roundCornersToFormCircle()
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        updateShimmerMaskLayerLayout()
    }
    
    func maxBackgroundLeadingConstraintConstant() -> CGFloat {
        let thumbViewPadding = thumbViewTopPaddingConstraint.constant
        return backgroundView.superview!.bounds.width - (thumbViewPadding * 2 + thumbView.frame.width)
    }
    
    func updateShimmerMaskLayerLayout() {
        guard let shimmerMaskLayer = informationalLabel.layer.mask else {
            return
        }
        
        // Start the mask just offscreen on the left side of the super layer and centered
        shimmerMaskLayer.frame.origin = CGPoint(x: -shimmerMaskLayer.frame.width,
                                                y: informationalLabel.layer.bounds.height / 2.0 - shimmerMaskLayer.bounds.height / 2.0)
        
        // Create the horizontal animation to move the shimmer mask
        let shimmerAnimation = CABasicAnimation(keyPath: "position.x")
        shimmerAnimation.byValue = informationalLabel.bounds.width + shimmerMaskLayer.frame.width
        shimmerAnimation.repeatCount = HUGE
        shimmerAnimation.duration = 2.5
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shimmerMaskLayer.add(shimmerAnimation, forKey: "shimmerAnimation")
    }
    
    // MARK: - Working with slider value
    
    func updateValue() {
        let currentValue = max(0.0, min(1.0, Double(backgroundLeadingConstraint.constant / maxBackgroundLeadingConstraintConstant())))
        
        if value != currentValue {
            value = currentValue
            sendActions(for: [.valueChanged])
        }
    }
    
    func updatePowerOffLabel() {
        // Hide the power off label when the slider is panned
        let desiredPowerOffLabelAlpha: CGFloat = (value == 0) ? 1.0 : 0.0
        if self.informationalLabel.alpha != desiredPowerOffLabelAlpha {
            UIView.animate(withDuration: 0.10, animations: {
                self.informationalLabel.alpha = desiredPowerOffLabelAlpha
                self.backgroundInformationalLabel.alpha = desiredPowerOffLabelAlpha
            })
        }
    }
    
    // MARK: - Gesture Handling
    
    func thumbViewWasPanned(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible, .began:
            break
            
        case .changed:
            // Update the leading constraint to move the slider to match
            // the user's pan gesture
            let translation = recognizer.translation(in: self)
            backgroundLeadingConstraint.constant = max(translation.x, 0)
            updateValue()
            
        case .ended, .cancelled, .failed:
            // Determine whether the user slid the slider far enough to
            // either have the slider finish to the end position or slide
            // back to the start position
            let startValue = value
            let shouldSlideToEnd = startValue > 0.5
            
            let _ = DisplayLinkProgressor.run(withDuration: 0.10, update: { (progress) in
                let finalValue = shouldSlideToEnd ? 1.0 : 0.0
                let nextValue = startValue + progress * (finalValue - startValue)
                
                self.value = nextValue
            })
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        sendActions(for: [.touchDown])
    }
}
