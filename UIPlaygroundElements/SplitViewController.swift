//
//  SplitViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/29/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // Let the child view controllers decide how the status bar should look
        if let childVC = viewControllers.last {
            return childVC.preferredStatusBarStyle
        }
        
        return super.preferredStatusBarStyle
    }
}
