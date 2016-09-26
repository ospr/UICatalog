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
    
    init(appInfo: SpringBoardAppInfo, appIconFrame: CGRect) {
        self.appInfo = appInfo
        self.appIconFrame = appIconFrame
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: fromViewController)
        
        let toViewSnapshot = toView.snapshotView(afterScreenUpdates: true)!
        toViewSnapshot.frame = appIconFrame
        toViewSnapshot.layer.cornerRadius = 20
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

        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/10, animations: {
                appIconImageView.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                toViewSnapshot.frame = finalFrame
                toViewSnapshot.layer.cornerRadius = 0
            })
            }, completion: { _ in
                toView.isHidden = false
                toViewSnapshot.removeFromSuperview()
                appIconImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
