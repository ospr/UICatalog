//
//  UINavigationControllerExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/29/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

public class NavigationController: UINavigationController {

    override init(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        delegate = self
    }
    
    public override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        // When the status bar hidden state changes we may need to update
        // the status bar appearance now that our nav bar may or may not be
        // hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        // If the navbar is hidden, then let the visible view controller decide the
        // status bar style
        if navigationBar.isHidden, let topViewController = self.topViewController {
            return topViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = self.topViewController {
            return topViewController.supportedInterfaceOrientations
        }
        
        return super.supportedInterfaceOrientations
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // Allow view controllers to specify whether they would like to have the navbar
        // hidden when shown. This allows us to move the logic for determining when to
        // hide the bar to the parent controller rather than having the child deal with it
        let shouldHideNavigationBar: Bool = {
            guard let hideableViewController = viewController as? ViewControllerNavigationBarHideable else {
                return false
            }
            
            return hideableViewController.prefersNavigationBarHidden
        }()
        
        if isNavigationBarHidden != shouldHideNavigationBar {
            setNavigationBarHidden(shouldHideNavigationBar, animated: true)
        }
    }
}

public protocol ViewControllerNavigationBarHideable {
    
    var prefersNavigationBarHidden: Bool { get }
}
