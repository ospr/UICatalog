//
//  SpringBoardAppLaunchTransitionAnimator.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/26/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

class SpringBoardAppLaunchTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let appInfo: SpringBoardAppInfo
    let appIconFrame: CGRect
    
    var startingCornerRadius = CGFloat(14)
    var duration = TimeInterval(1)
    
    init(appInfo: SpringBoardAppInfo, appIconFrame: CGRect) {
        self.appInfo = appInfo
        self.appIconFrame = appIconFrame
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: fromViewController)
        
        let toViewSnapshot = toView.snapshotView(afterScreenUpdates: true)!
        toViewSnapshot.frame = appIconFrame
        toViewSnapshot.layer.masksToBounds = true
        
        containerView.addSubview(toView)
        containerView.addSubview(toViewSnapshot)
        toView.isHidden = true
        
        let appIconImageView = UIImageView()
        appIconImageView.image = appInfo.image
        appIconImageView.frame = toViewSnapshot.bounds
        toViewSnapshot.addSubview(appIconImageView)
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.anchorConstraintsToFitSuperview()
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/10, animations: {
                appIconImageView.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                toViewSnapshot.frame = finalFrame
            })
            }, completion: { _ in
                toView.isHidden = false
                toViewSnapshot.removeFromSuperview()
                appIconImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        // Animate corner radius seprately since CALayer properties can't be animated
        // directly by using UIView animation mechanisms
        toViewSnapshot.layer.cornerRadius = 0
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fromValue = startingCornerRadius
        animation.toValue = toViewSnapshot.layer.cornerRadius
        animation.duration = duration
        toViewSnapshot.layer.add(animation, forKey: "cornerRadius")
    }
}
