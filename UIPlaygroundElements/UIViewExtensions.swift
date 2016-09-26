//
//  UIViewExtentions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

// MARK: - Nib/Xib Support

public extension UIView {
    
    public func addOwnedViewFrom(nibNamed nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let ownedView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(ownedView)
        ownedView.translatesAutoresizingMaskIntoConstraints = false
        ownedView.anchorConstraintsToFitSuperview()
        
        return ownedView
    }
}

// MARK: - Autolayout Support

public extension UIView {
    
    public func anchorConstraintsToFitSuperview() {
        guard let superview = self.superview else {
            return
        }
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    public func anchorConstraintsToCenterInSuperview() {
        guard let superview = superview else {
            return
        }
        
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }

    public func anchorConstraintsProporitonalSizeToSuperview(multiplier: CGFloat = 1.0) {
        guard let superview = superview else {
            return
        }
        
        heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: multiplier).isActive = true
        widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: multiplier).isActive = true
    }
}

// MARK: - Layer Support

public extension UIView {
    
    public func roundCornersToFormCircle() {
        layer.cornerRadius = bounds.size.width / 2.0
    }
}

// MARK: - Snapshot Support

public extension UIView {
    
    public func snapshot(withScale scale: CGFloat, afterScreenUpdates: Bool = false) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { (context) in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
