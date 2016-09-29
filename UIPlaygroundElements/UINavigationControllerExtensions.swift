//
//  UINavigationControllerExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/29/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

open class NavigationController: UINavigationController {
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        // When the status bar hidden state changes we may need to update
        // the status bar appearance now that our nav bar may or may not be
        // hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // If the navbar is hidden, then let the visible view controller decide the
        // status bar style
        if navigationBar.isHidden, let visibleViewController = self.visibleViewController {
            return visibleViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }
}
