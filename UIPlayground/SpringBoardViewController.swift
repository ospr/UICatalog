//
//  SpringBoardViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UIPlaygroundElements

public class SpringBoardViewController: UIViewController {
    
    // TODO: clean this up
    var selectedAppInfo: SpringBoardAppInfo?
    var selectedAppFrame: CGRect?
    
    var appIconLayoutInfoItems = [
        [
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
        ],
        [
            SpringBoardAppInfo(appName: "UIPlayground", image: UIImage(named: "AppCard-UIPlayground-Icon")!),
            SpringBoardAppInfo(appName: "Overcast", image: UIImage(named: "AppCard-Overcast-Icon")!),
        ],
        [
            SpringBoardAppInfo(appName: "DavisTrans", image: UIImage(named: "AppCard-DavisTrans-Icon")!),
        ],
    ]
    
    public var wallpaperImage: UIImage? {
        didSet {
            view.layoutIfNeeded()
            wallpaperView.image = prepareWallpaperImage(image: wallpaperImage)
        }
    }
    
    let containerView = UIView()
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pageViewSubViewControllers = [UIViewController]()
    let dockView = SpringBoardDockView()
    let wallpaperView = UIImageView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        title = "Spring Board"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override public func viewDidLoad() {
        pageViewSubViewControllers = appIconLayoutInfoItems.map({ (appInfoItems) -> SpringBoardAppCollectionViewController in
            let controller = SpringBoardAppCollectionViewController()
            controller.appInfoItems = appInfoItems
            controller.delegate = self
            
            return controller
        })
        pageViewController.setViewControllers([pageViewSubViewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        
        // Add wallpaper view
        view.addSubview(wallpaperView)
        wallpaperView.translatesAutoresizingMaskIntoConstraints = false
        wallpaperView.anchorConstraintsToFitSuperview()
        
        view.addSubview(containerView)
        containerView.isOpaque = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.anchorConstraintsToFitSuperview()
        
        // Add page view
        // TODO: do the view controller child methods here too
        containerView.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // Add dock view
        containerView.addSubview(dockView)
        dockView.translatesAutoresizingMaskIntoConstraints = false
        dockView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        dockView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dockView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dockView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Constrain top of dock to bottom of page view
        dockView.topAnchor.constraint(equalTo: pageViewController.view.bottomAnchor).isActive = true
        
        wallpaperImage = UIImage(named: "BackgroundWallpaper", inBundleForObject: self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Working with wallpaper
    
    private func prepareWallpaperImage(image: UIImage?) -> UIImage? {
        guard var newImage = image else {
            return nil
        }
        
        // Resize image so that it's just big enough for the wallpaper view
        // This will increase performance when applying to effects below
        let imageRect = wallpaperView.bounds
        UIGraphicsBeginImageContextWithOptions(imageRect.size, true, 0)
        newImage.draw(in: imageRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        guard var newCGImage = newImage.cgImage else {
            return nil
        }
        
        // Apply a blur effect
        if let blurFilter = CIFilter(name: "CIGaussianBlur") {
            let start = Date()
            
            let ciContext = CIContext()
            let ciImage = CIImage(cgImage: newCGImage)
            blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
            blurFilter.setValue(1, forKey: kCIInputRadiusKey)
            
            let outputCIImage = blurFilter.value(forKey: kCIOutputImageKey) as! CIImage
            newCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent)!
            
            print("time: \(-start.timeIntervalSinceNow)")
        }
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw image (must flip the coordinate system first)
        context.saveGState()
        context.translateBy(x: 0, y: imageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(newCGImage, in: imageRect)
        context.restoreGState()
        
        // Draw a transparent dark overlay to dim the image
        context.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        let path = UIBezierPath(rect: imageRect)
        path.fill()
        
        // Get final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}

extension SpringBoardViewController: UIPageViewControllerDataSource {
    
    func nextPageViewControllerFor(viewController: UIViewController, before: Bool) -> UIViewController? {
        let currentIndex = pageViewSubViewControllers.index(of: viewController)!
        let nextIndex = max(0, min(pageViewSubViewControllers.count - 1, before ? currentIndex - 1 : currentIndex + 1))
        let nextViewController = pageViewSubViewControllers[nextIndex]
        
        guard nextViewController !== viewController else {
            return nil
        }
        
        return nextViewController
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextPageViewControllerFor(viewController: viewController, before: true)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextPageViewControllerFor(viewController: viewController, before: false)
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return appIconLayoutInfoItems.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    // todo: is this correct?
        return 0
    }
}

extension SpringBoardViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: try not to use ! here?
        return SpringBoardAppLaunchTransitionAnimator(appInfo: selectedAppInfo!, appIconFrame: selectedAppFrame!, springBoardViewController: self)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: finish this
        return nil
    }
}

extension SpringBoardViewController: SpringBoardAppCollectionViewControllerDelegate {
    
    func springBoardAppCollectionViewController(viewController: SpringBoardAppCollectionViewController, didSelectAppInfo appInfo: SpringBoardAppInfo, selectionRect: CGRect) {
        selectedAppInfo = appInfo
        selectedAppFrame = selectionRect
        
        // TODO: finish this
        let viewController = SpringBoardLaunchedAppViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
}
