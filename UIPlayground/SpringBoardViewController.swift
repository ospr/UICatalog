//
//  SpringBoardViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SpringBoardViewController: UIViewController {
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let dockView = UIView()
    
    override func viewDidLoad() {
        // TODO: set correct vc here
        pageViewController.setViewControllers([SpringBoardAppCollectionViewController()], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        
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
        
        dockView.backgroundColor = .red // TODO: remove this
    }
}

extension SpringBoardViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // TODO: return correct vc here
        return SpringBoardAppCollectionViewController()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // TODO: return correct vc here
        return SpringBoardAppCollectionViewController()
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        // TODO: return correct value
        return 3
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        // TODO: return correct value
        return 1
    }
}
