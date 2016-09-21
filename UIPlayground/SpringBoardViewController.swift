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
    
    var appIconLayoutInfoItems = [
        [
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
        get { return wallpaperView.image }
        set { wallpaperView.image = newValue }
    }
    
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
            
            return controller
        })
        pageViewController.setViewControllers([pageViewSubViewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        
        // Add wallpaper view
        view.addSubview(wallpaperView)
        wallpaperView.translatesAutoresizingMaskIntoConstraints = false
        wallpaperView.anchorConstraintsToFitSuperview()
        wallpaperImage = UIImage(named: "BackgroundWallpaper", inBundleForObject: self)
        
        // Add page view
        // TODO: do the view controller child methods here too
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // Add dock view
        view.addSubview(dockView)
        dockView.translatesAutoresizingMaskIntoConstraints = false
        dockView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        dockView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dockView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dockView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Constrain top of dock to bottom of page view
        dockView.topAnchor.constraint(equalTo: pageViewController.view.bottomAnchor).isActive = true
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
