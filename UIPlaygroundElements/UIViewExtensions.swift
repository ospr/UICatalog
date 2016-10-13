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
        
        anchorConstraintsToCenterIn(superview)
    }

    public func anchorConstraintsToCenterIn(_ view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
    
    public func snapshotImage(withScale scale: CGFloat = 0, afterScreenUpdates: Bool = false) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { (context) in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
    
    func fullWindowHierarchySnapshotImage(with scale: CGFloat? = nil, afterScreenUpdates: Bool = false) -> UIImage? {
        guard let window = window else { return nil }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale ?? window.screen.scale
        format.opaque = true
        
        let drawBounds = CGRect(x: -frame.origin.x, y: -frame.origin.y,
                                width: window.frame.width, height: window.frame.height)
        
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { (context) in
            window.drawHierarchy(in: drawBounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
