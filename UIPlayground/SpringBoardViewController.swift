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
    var selectedAppButton: UIButton?
    
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
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // Have the presented view controller specify the status bar style
        if let presentedViewController = presentedViewController, !presentedViewController.isBeingDismissed {
            return presentedViewController.preferredStatusBarStyle
        }
        
        return .lightContent
    }
    
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
        pageViewController.willMove(toParentViewController: self)
        containerView.addSubview(pageViewController.view)
        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)
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
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    // MARK: - Working with wallpaper
    
    private func prepareWallpaperImage(image: UIImage?) -> UIImage? {
        guard let image = image else {
            return nil
        }

        let imageRect = wallpaperView.bounds
        
        return UIGraphicsImageRenderer(size: imageRect.size, scale: 0, opaque: true).image { (context) in
            // Resize image so that it's just big enough for the wallpaper view
            image.draw(in: imageRect)
            
            // Draw a transparent dark overlay to dim the image
            context.cgContext.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            let path = UIBezierPath(rect: imageRect)
            path.fill()
        }
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
        return SpringBoardAppLaunchTransitionAnimator(appIconButton: selectedAppButton!, springBoardViewController: self, reversed: false)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: finish this
        return SpringBoardAppLaunchTransitionAnimator(appIconButton: selectedAppButton!, springBoardViewController: self, reversed: true)
    }
}

extension SpringBoardViewController: SpringBoardAppCollectionViewControllerDelegate {
    
    func springBoardAppCollectionViewController(_ viewController: SpringBoardAppCollectionViewController, didSelectAppInfo appInfo: SpringBoardAppInfo, selectedAppIconButton: UIButton) {
        selectedAppButton = selectedAppIconButton
        
        // TODO: finish this
        let viewController = SpringBoardLaunchedAppViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
}
