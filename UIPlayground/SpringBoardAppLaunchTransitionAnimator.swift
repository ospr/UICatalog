//
//  SpringBoardAppLaunchTransitionAnimator.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/26/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

class SpringBoardAppLaunchTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let reversed: Bool
    let appInfo: SpringBoardAppInfo
    let appIconButton: UIButton
    let springBoardViewController: SpringBoardViewController
    
    var startingCornerRadius = CGFloat(14)
    var otherAppZoomScale = CGFloat(5)
    var wallpaperZoomScale = CGFloat(1.5)
    var duration = TimeInterval(10.3)
    
    init(appInfo: SpringBoardAppInfo, appIconButton: UIButton, springBoardViewController: SpringBoardViewController, reversed: Bool) {
        self.appInfo = appInfo
        self.appIconButton = appIconButton
        self.springBoardViewController = springBoardViewController
        self.reversed = reversed
        
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
        let appInitialView = reversed ? fromViewController.view! : toView
        
        print("duration: \(duration), toViewController: \(toViewController), fromViewController: \(fromViewController)")
        
        let wallpaperSnapshotView = springBoardViewController.wallpaperView.snapshotView(afterScreenUpdates: false)!
        containerView.addSubview(wallpaperSnapshotView)
        wallpaperSnapshotView.frame = containerView.bounds
        
        let appCollectionSnapshotView = UIImageView()
        appCollectionSnapshotView.image = snapshotImageForZoomingAppIcons(from: springBoardViewController)
        // Move the anchor point to the center of the app that is being launched so that
        // the zoom animation will look like we are going into that app
        appCollectionSnapshotView.layer.anchorPoint = CGPoint(x: appIconFrame.midX / containerView.bounds.maxX,
                                                              y: appIconFrame.midY / containerView.bounds.maxY)
        appCollectionSnapshotView.frame = containerView.bounds
        containerView.addSubview(appCollectionSnapshotView)
        
        let appInitialViewSnapshot = appInitialView.snapshotView(afterScreenUpdates: true)!
        appInitialViewSnapshot.frame = appIconFrame
        appInitialViewSnapshot.layer.masksToBounds = true
        
        if !reversed {
            containerView.addSubview(toView)
        }
        containerView.addSubview(appInitialViewSnapshot)
        toView.isHidden = true
        
        let appIconImageView = UIImageView()
        appIconImageView.image = appInfo.image
        appIconImageView.frame = appInitialViewSnapshot.bounds
        appInitialViewSnapshot.addSubview(appIconImageView)
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.anchorConstraintsToFitSuperview()
        
        let curveProvider = UICubicTimingParameters(animationCurve: reversed ? .easeIn : .easeOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: curveProvider)
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/10, animations: {
                    appIconImageView.alpha = 0
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                    appInitialViewSnapshot.frame = finalFrame
                    appCollectionSnapshotView.alpha = 0
                    appCollectionSnapshotView.transform = CGAffineTransform(scaleX: self.otherAppZoomScale, y: self.otherAppZoomScale)
                    wallpaperSnapshotView.transform = CGAffineTransform(scaleX: self.wallpaperZoomScale, y: self.wallpaperZoomScale)
                })
                }, completion: { _ in
                    toView.isHidden = false
                    appInitialViewSnapshot.removeFromSuperview()
                    appIconImageView.removeFromSuperview()
                    appCollectionSnapshotView.removeFromSuperview()
                    wallpaperSnapshotView.removeFromSuperview()
                    self.springBoardViewController.containerView.isHidden = false
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
        // TODO: clean up
        animator.isInterruptible = true
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = reversed ? 1 : 0
        animator.isReversed = reversed
        animator.startAnimation()
        
        // Animate corner radius seprately since CALayer properties can't be animated
        // directly by using UIView animation mechanisms
        let startRadius = reversed ? 0 : startingCornerRadius
        let endRadius = reversed ? startingCornerRadius : 0
        appInitialViewSnapshot.layer.cornerRadius = endRadius
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fromValue = startRadius
        animation.toValue = appInitialViewSnapshot.layer.cornerRadius
        animation.duration = duration
        appInitialViewSnapshot.layer.add(animation, forKey: "cornerRadius")
    }
    
    func snapshotImageForZoomingAppIcons(from viewController: SpringBoardViewController) -> UIImage {
        let springBoardView = viewController.containerView
        // Slightly increase the scale here so that when the image is zoomed things still look sharp
        let imageScale = springBoardView.window!.screen.scale * 2

        // Get a snapshot of the app collection without the selected button
        appIconButton.isHidden = true
        let snapshotImage = springBoardView.snapshotImage(with: imageScale, afterScreenUpdates: true)
        appIconButton.isHidden = false
        
        // Here we cheat a little bit by getting a snapshot of the dock using the full window
        // hierarchy (b/c it is a visual effect view, otherwise it doesn't retain the blur) and
        // placing it in the dock location of the original snapshot. The animation won't be perfect
        // but it's quick enough that the user won't notice this little cheat
        let dockSnapshotImage = viewController.dockView.fullWindowHierarchySnapshotImage(with: imageScale)!
        
        let imageBounds = springBoardView.bounds
        let finalImage = UIGraphicsImageRenderer(size: imageBounds.size, scale: imageScale, opaque: false).image { (context) in
            snapshotImage.draw(in: imageBounds)
            dockSnapshotImage.draw(in: viewController.dockView.frame)
        }

        return finalImage
    }
}
