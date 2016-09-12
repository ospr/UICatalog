//
//  UIViewExtentions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

// MARK: - Nib/Xib Support

extension UIView {
    
    func addOwnedViewFrom(nibNamed nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        let ownedView = nib.instantiateWithOwner(self, options: nil).first as! UIView
        
        addSubview(ownedView)
        ownedView.translatesAutoresizingMaskIntoConstraints = false
        ownedView.anchorConstraintsToFitSuperview()
        
        return ownedView
    }
}

// MARK: - Autolayout Support

extension UIView {
    
    func anchorConstraintsToFitSuperview() {
        guard let superview = self.superview else {
            return
        }
        
        leadingAnchor.constraintEqualToAnchor(superview.leadingAnchor).active = true
        trailingAnchor.constraintEqualToAnchor(superview.trailingAnchor).active = true
        topAnchor.constraintEqualToAnchor(superview.topAnchor).active = true
        bottomAnchor.constraintEqualToAnchor(superview.bottomAnchor).active = true
    }
}

// MARK: - Layer Support

extension UIView {
    
    func roundCornersToFormCircle() {
        layer.cornerRadius = bounds.size.width / 2.0
    }
}
