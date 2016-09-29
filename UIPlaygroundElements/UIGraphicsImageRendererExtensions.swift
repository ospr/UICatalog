//
//  UIGraphicsImageRendererExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/29/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

public extension UIGraphicsImageRendererFormat {
    
    public convenience init(scale: CGFloat, opaque: Bool) {
        self.init()
        
        self.scale = scale
        self.opaque = opaque
    }
}

public extension UIGraphicsImageRenderer {

    public convenience init(size: CGSize, scale: CGFloat, opaque: Bool) {
        let bounds = CGRect(origin: .zero, size: size)
        
        self.init(bounds: bounds, scale: scale, opaque: opaque)
    }
    
    public convenience init(bounds: CGRect, scale: CGFloat, opaque: Bool) {
        let format = UIGraphicsImageRendererFormat(scale: scale, opaque: opaque)
        
        self.init(bounds: bounds, format: format)
    }
}
