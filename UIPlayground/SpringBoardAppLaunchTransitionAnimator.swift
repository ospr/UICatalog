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
    let springBoardViewController: SpringBoardViewController
    
    var startingCornerRadius = CGFloat(14)
    var otherAppZoomScale = CGFloat(5)
    var wallpaperZoomScale = CGFloat(1.5)
    var duration = TimeInterval(0.3)
    
    init(appInfo: SpringBoardAppInfo, appIconFrame: CGRect, springBoardViewController: SpringBoardViewController) {
        self.appInfo = appInfo
        // TODO: fix the need for an offset here
        self.appIconFrame = appIconFrame.offsetBy(dx: -10, dy: 0)
        self.springBoardViewController = springBoardViewController
        
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
                appCollectionSnapshotView.alpha = 0
                appCollectionSnapshotView.transform = CGAffineTransform(scaleX: self.otherAppZoomScale, y: self.otherAppZoomScale)
                wallpaperSnapshotView.transform = CGAffineTransform(scaleX: self.wallpaperZoomScale, y: self.wallpaperZoomScale)
            })
            }, completion: { _ in
                toView.isHidden = false
                toViewSnapshot.removeFromSuperview()
                appIconImageView.removeFromSuperview()
                appCollectionSnapshotView.removeFromSuperview()
                wallpaperSnapshotView.removeFromSuperview()
                self.springBoardViewController.containerView.isHidden = false
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
    
    func snapshotImageForZoomingAppIcons(from viewController: SpringBoardViewController) -> UIImage {
        let springBoardView = viewController.containerView
        // Slightly increase the scale here so that when the image is zoomed things still look sharp
        let imageScale = springBoardView.window!.screen.scale * 2

        // Here we cheat a little bit by getting a snapshot of the dock using the full window
        // hierarchy (b/c it is a visual effect view, otherwise it doesn't retain the blur) and
        // placing it in the dock location of the original snapshot. The animation won't be perfect
        // but it's quick enough that the user won't notice this little cheat
        let snapshotImage = springBoardView.snapshotImage(with: imageScale, afterScreenUpdates: false)
        let dockSnapshotImage = viewController.dockView.fullWindowHierarchySnapshotImage(with: imageScale)!
        
        let imageBounds = springBoardView.bounds
        let format = UIGraphicsImageRendererFormat()
        format.scale = imageScale
        format.opaque = false
        let finalImage = UIGraphicsImageRenderer(bounds: imageBounds, format: format).image { (context) in
            snapshotImage.draw(in: imageBounds)
            dockSnapshotImage.draw(in: viewController.dockView.frame)
        }

        return finalImage
    }
}
