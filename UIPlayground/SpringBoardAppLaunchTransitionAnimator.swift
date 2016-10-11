//
//  SpringBoardAppLaunchTransitionAnimator.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/26/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

class SpringBoardAppLaunchTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    let appIconButton: UIButton
    let springBoardViewController: SpringBoardViewController
    
    var startingCornerRadius = CGFloat(14)
    var otherAppZoomScale = CGFloat(5)
    var wallpaperZoomScale = CGFloat(1.5)
    var duration = TimeInterval(0.3)
    
    init(appIconButton: UIButton, springBoardViewController: SpringBoardViewController, isPresenting: Bool) {
        self.appIconButton = appIconButton
        self.springBoardViewController = springBoardViewController
        self.isPresenting = isPresenting
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let appIconFrame = appIconButton.convert(appIconButton.frame, to: nil)
        
//        todo: clean this up
        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = toViewController.view!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: fromViewController)
        
        // TODO: clean up !
        let appInitialView = isPresenting ? fromViewController.view! : toView
        
        print("duration: \(duration), toViewController: \(toViewController), fromViewController: \(fromViewController)")
        
        let wallpaperSnapshotView = springBoardViewController.wallpaperView.snapshotView(afterScreenUpdates: false)!
        containerView.addSubview(wallpaperSnapshotView)
        wallpaperSnapshotView.frame = containerView.bounds
        
        let appCollectionContainerView = UIView()
        // Move the anchor point to the center of the app that is being launched so that
        // the zoom animation will look like we are going into that app
        appCollectionContainerView.layer.anchorPoint = CGPoint(x: appIconFrame.midX / containerView.bounds.maxX,
                                                               y: appIconFrame.midY / containerView.bounds.maxY)
        appCollectionContainerView.frame = containerView.bounds
        containerView.addSubview(appCollectionContainerView)
        
        let dockViewSnapshot = SpringBoardDockView()
        appCollectionContainerView.addSubview(dockViewSnapshot)
        dockViewSnapshot.frame = springBoardViewController.dockView.frame
        dockViewSnapshot.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        let appCollectionSnapshotView = UIImageView()
        appCollectionContainerView.addSubview(appCollectionSnapshotView)
        appCollectionSnapshotView.image = snapshotImageForZoomingAppIcons(from: springBoardViewController)
        appCollectionSnapshotView.frame = appCollectionContainerView.bounds
        
        let appInitialViewSnapshot = appInitialView.snapshotView(afterScreenUpdates: true)!
        
        // TODO: can this be moved to the end of the animation?
        if !isPresenting {
            containerView.addSubview(toView)
        }
        toView.isHidden = true
        
        let appIconContainerView = UIView(frame: appIconFrame)
        containerView.addSubview(appIconContainerView)
        
        let appIconImageView = appIconButton.snapshotView(afterScreenUpdates: false)!
        appIconContainerView.addSubview(appIconImageView)
        // TODO: why don't these autolayout constraints work?
        appIconImageView.frame = appIconContainerView.bounds
        appIconImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // TODO: why don't these autolayout constraints work?
//        appInitialViewSnapshot.translatesAutoresizingMaskIntoConstraints = false
//        appInitialViewSnapshot.anchorConstraintsToFitSuperview()
        appIconContainerView.addSubview(appInitialViewSnapshot)
        appInitialViewSnapshot.frame = appIconContainerView.bounds
        appInitialViewSnapshot.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        appInitialViewSnapshot.alpha = 0
        
        
        let curveProvider = UICubicTimingParameters(animationCurve: isPresenting ? .easeIn : .easeOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: curveProvider)
        
        // TODO: constants for these
        let alphaDuration = isPresenting ? 9/10.0 : 1 / 10.0
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: alphaDuration, animations: {
                    appInitialViewSnapshot.alpha = 1
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                    appIconContainerView.frame = finalFrame
                    appCollectionSnapshotView.alpha = 0
                    appCollectionContainerView.transform = CGAffineTransform(scaleX: self.otherAppZoomScale, y: self.otherAppZoomScale)
                    wallpaperSnapshotView.transform = CGAffineTransform(scaleX: self.wallpaperZoomScale, y: self.wallpaperZoomScale)
                })
                }, completion: { _ in
                    toView.isHidden = false
                    appIconContainerView.removeFromSuperview()
                    appInitialViewSnapshot.removeFromSuperview()
                    appIconImageView.removeFromSuperview()
                    appCollectionSnapshotView.removeFromSuperview()
                    wallpaperSnapshotView.removeFromSuperview()
                    appCollectionContainerView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
        // TODO: clean up
        animator.isInterruptible = true
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = isPresenting ? 1 : 0
        animator.isReversed = isPresenting
        animator.startAnimation()
        
        // Animate corner radius seprately since CALayer properties can't be animated
        // directly by using UIView animation mechanisms
        let startRadius = isPresenting ? 0 : startingCornerRadius
        let endRadius = isPresenting ? startingCornerRadius : 0
        appIconContainerView.layer.cornerRadius = endRadius
        appIconContainerView.clipsToBounds = true
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fromValue = startRadius
        animation.toValue = appIconContainerView.layer.cornerRadius
        animation.duration = duration
        appIconContainerView.layer.add(animation, forKey: "cornerRadius")
    }
    
    func snapshotImageForZoomingAppIcons(from viewController: SpringBoardViewController) -> UIImage {
        let springBoardView = viewController.containerView
        // Slightly increase the scale here so that when the image is zoomed things still look sharp
        let imageScale = springBoardView.window!.screen.scale * 2

        // Get a snapshot of the app collection without the selected button
        // TODO: is this causing flickering?
        appIconButton.isHidden = true
        viewController.dockView.isHidden = true
        let snapshotImage = springBoardView.snapshotImage(withScale: imageScale, afterScreenUpdates: true)
        appIconButton.isHidden = false
        viewController.dockView.isHidden = false
        
        let imageBounds = springBoardView.bounds
        let finalImage = UIGraphicsImageRenderer(size: imageBounds.size, scale: imageScale, opaque: false).image { (context) in
            snapshotImage.draw(in: imageBounds)
        }

        return finalImage
    }
}
