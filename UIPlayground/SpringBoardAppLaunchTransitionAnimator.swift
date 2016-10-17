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
    var duration = TimeInterval(0.5)
    var animationTimingParameters = UISpringTimingParameters(dampingRatio: 4.56)
    
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
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)!
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toView = toViewController.view!
        
        let finalFrame = transitionContext.finalFrame(for: fromViewController)
        let appInitialView = isPresenting ? toView : fromViewController.view!
        let appIconFrame = appIconButton.convert(appIconButton.frame, to: nil)
        
        let wallpaperSnapshotView = springBoardViewController.wallpaperView.simulatorFix_snapshotView(afterScreenUpdates: false)!
        containerView.addSubview(wallpaperSnapshotView)
        
        let (appCollectionContainerView, appCollectionSnapshotView) = setupAppCollectionContainerView(for: containerView.bounds, appIconFrame: appIconFrame)
        containerView.addSubview(appCollectionContainerView)
        
        let (appIconContainerView, appInitialViewSnapshot) = setupAppIconContainerView(for: appIconFrame, with: appInitialView)
        containerView.addSubview(appIconContainerView)

        // Initialize frame values
        appCollectionContainerView.frame = containerView.bounds
        wallpaperSnapshotView.frame = containerView.bounds
        appIconContainerView.frame = appIconFrame

        // Setup a block used for updating views for animation states
        let updateViewsForAnimation: (Bool) -> () = { isLaunched in
            appCollectionContainerView.transform = isLaunched ? CGAffineTransform(scaleX: self.otherAppZoomScale, y: self.otherAppZoomScale) : CGAffineTransform.identity
            wallpaperSnapshotView.transform = isLaunched ? CGAffineTransform(scaleX: self.wallpaperZoomScale, y: self.wallpaperZoomScale) : CGAffineTransform.identity
            appIconContainerView.frame = isLaunched ? finalFrame : appIconFrame
            appCollectionSnapshotView.alpha = isLaunched ? 0 : 1
            appInitialViewSnapshot.alpha = isLaunched ? 2 : 0
        }
        
        // Initialize views for the current state (not the end animated state)
        updateViewsForAnimation(!isPresenting)
        
        // Build animation
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: animationTimingParameters)
        animator.addAnimations {
            updateViewsForAnimation(self.isPresenting)
        }
        animator.addCompletion { (position) in
            appIconContainerView.removeFromSuperview()
            wallpaperSnapshotView.removeFromSuperview()
            appCollectionContainerView.removeFromSuperview()
            
            if self.isPresenting {
                containerView.addSubview(toView)
            }
            
            transitionContext.completeTransition(position == .end && !transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
        
        // Animate corner radius seprately since CALayer properties can't be animated
        // directly by using UIView animation mechanisms
        let startRadius = isPresenting ? startingCornerRadius : 0
        let endRadius = isPresenting ? 0 : startingCornerRadius
        appIconContainerView.layer.cornerRadius = endRadius
        appIconContainerView.clipsToBounds = true
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = startRadius
        animation.toValue = appIconContainerView.layer.cornerRadius
        animation.duration = duration * 0.65
        appIconContainerView.layer.add(animation, forKey: "cornerRadius")
    }
    
    // MARK: - Setting up views
    
    private func setupAppCollectionContainerView(for bounds: CGRect, appIconFrame: CGRect) -> (UIView, UIView) {
        let appCollectionContainerView = UIView()
        // Move the anchor point to the center of the app that is being launched so that
        // the zoom animation will look like we are going into that app
        appCollectionContainerView.layer.anchorPoint = CGPoint(x: appIconFrame.midX / bounds.maxX,
                                                               y: appIconFrame.midY / bounds.maxY)
        appCollectionContainerView.frame = bounds
        
        let dockViewSnapshot = SpringBoardDockView()
        let currentDockViewFrame = springBoardViewController.dockView.frame
        appCollectionContainerView.addSubview(dockViewSnapshot)
        dockViewSnapshot.frame = CGRect(x: currentDockViewFrame.origin.x, y: currentDockViewFrame.origin.y,
                                        width: appCollectionContainerView.bounds.width, height: currentDockViewFrame.height)
        dockViewSnapshot.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        let appCollectionSnapshotView = UIImageView()
        appCollectionContainerView.addSubview(appCollectionSnapshotView)
        appCollectionSnapshotView.image = snapshotImageForZoomingAppIcons(from: springBoardViewController)
        appCollectionSnapshotView.frame = appCollectionContainerView.bounds
        appCollectionSnapshotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return (appCollectionContainerView, appCollectionSnapshotView)
    }
    
    private func setupAppIconContainerView(for appIconFrame: CGRect, with appInitialView: UIView) -> (UIView, UIView) {
        // Note on iPhone 7/7+ simulator there is a white flicker when calling this with true set
        // rdar://28808781
        let appInitialViewSnapshot = appInitialView.simulatorFix_snapshotView(afterScreenUpdates: true)!

        let appIconContainerView = UIView()
        
        let appIconImageView = appIconButton.simulatorFix_snapshotView(afterScreenUpdates: false)!
        appIconContainerView.addSubview(appIconImageView)
        appIconImageView.frame = appIconContainerView.bounds
        appIconImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        appIconContainerView.addSubview(appInitialViewSnapshot)
        appInitialViewSnapshot.frame = appIconContainerView.bounds
        appInitialViewSnapshot.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        return (appIconContainerView, appInitialViewSnapshot)
    }
    
    // MARK: - Creating snapshots
    
    private func snapshotImageForZoomingAppIcons(from viewController: SpringBoardViewController) -> UIImage {
        let springBoardView = viewController.containerView
        // Slightly increase the scale here so that when the image is zoomed things still look sharp
        let imageScale = springBoardView.window!.screen.scale * 2

        // Get a snapshot of the app collection without the selected button
        let snapshotImage = springBoardView.snapshotImage(withScale: imageScale)
        
        // Mask out the app icon
        let imageBounds = springBoardView.bounds
        let finalImage = UIGraphicsImageRenderer(size: imageBounds.size, scale: imageScale, opaque: false).image { (context) in
            snapshotImage.draw(in: imageBounds)
            
            let appIconFrame = appIconButton.convert(appIconButton.frame, to: nil)
            UIColor.clear.setFill()
            context.fill(appIconFrame)
        }

        return finalImage
    }
}
