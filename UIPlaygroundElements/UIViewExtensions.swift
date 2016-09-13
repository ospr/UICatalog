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
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let ownedView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
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
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
}

// MARK: - Layer Support

extension UIView {
    
    func roundCornersToFormCircle() {
        layer.cornerRadius = bounds.size.width / 2.0
    }
}
