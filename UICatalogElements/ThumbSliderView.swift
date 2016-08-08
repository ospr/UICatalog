//
//  ThumbSliderView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

@IBDesignable
public class ThumbSliderView: UIView {
    
    @IBOutlet private(set) weak var backgroundView: UIView!
    @IBOutlet private(set) weak var thumbView: UIView!
    @IBOutlet private(set) weak var powerOffLabel: UIView!
    @IBOutlet private weak var backgroundLeadingConstraint: NSLayoutConstraint!

    @IBInspectable var backgroundViewColor: UIColor? {
        get { return backgroundView.backgroundColor }
        set { backgroundView.backgroundColor = newValue }
    }

    @IBInspectable var thumbViewColor: UIColor? {
        get { return thumbView.backgroundColor }
        set { thumbView.backgroundColor = newValue }
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
        
        backgroundView.backgroundColor = .whiteColor()
        thumbView.backgroundColor = .redColor()
        
        setupThumbView()
    }
    
    private func setupThumbView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(thumbViewWasPanned))
        thumbView.addGestureRecognizer(panGesture)
        panGesture.enabled = true
    }

    // MARK: - View Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: rounded corners don't look quite right
        backgroundView.layer.cornerRadius = backgroundView.bounds.size.height / 2.0
        thumbView.roundCornersToFormCircle()
    }
    
    // MARK: - Gesture Handling
    
    func thumbViewWasPanned(recognizer: UIPanGestureRecognizer) {
        // Note that slider is prevented from sliding past its end by making the
        // backgroundLeadingConstraint priority lower in the xib 

        let updatePowerOffLabel: () -> () = {
            // Hide the power off label when the slider is panned
            let desiredPowerOffLabelAlpha: CGFloat = (self.backgroundLeadingConstraint.constant == 0) ? 1.0 : 0.0
            if self.powerOffLabel.alpha != desiredPowerOffLabelAlpha {
                UIView.animateWithDuration(0.10, animations: {
                    self.powerOffLabel.alpha = desiredPowerOffLabelAlpha
                })
            }
        }
        
        switch recognizer.state {
        case .Possible, .Began:
            break
            
        case .Changed:
            // Update the leading constraint to move the slider to match
            // the user's pan gesture
            let translation = recognizer.translationInView(self)
            backgroundLeadingConstraint.constant = max(translation.x, 0)
            updatePowerOffLabel()
            
        case .Ended, .Cancelled, .Failed:
            layoutIfNeeded()
            
            // Determine whether the user slid the slider far enough to
            // either have the slider finish to the end position or slide
            // back to the start position
            let thumbViewCenterPointInRoot = convertPoint(thumbView.center, fromView: thumbView.superview)
            let shouldSlideToEnd = thumbViewCenterPointInRoot.x > bounds.midX // Past the middle point?
            let finalBackgroundLeadingConstraintConstant = shouldSlideToEnd ? self.backgroundView.superview!.bounds.maxX : 0
            
            print("\(thumbViewCenterPointInRoot.x) vs \(bounds.midX)")
            
            // Animate the slider either to the start or end depending on
            // whether the threshold was crossed when dragging
            UIView.animateWithDuration(0.10, animations: { 
                self.backgroundLeadingConstraint.constant = finalBackgroundLeadingConstraintConstant
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if finished {
                    updatePowerOffLabel()
                }
            })
        }
        
    }
}
