//
//  CAAnimationExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 10/28/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

public extension CAAnimation {
    
    public class func jitterAnimation() -> CAAnimation {
        let transforms = [
            CATransform3DMakeRotation(CGFloat.pi / 80, 0, 0, 1),
            CATransform3DMakeTranslation(-1, -1, 0),
            CATransform3DMakeRotation(-CGFloat.pi / 80, 0, 0, 1),
            CATransform3DMakeRotation(-CGFloat.pi / 73, 0, 0, 1),
        ]
        
        var values = NSValue.values(byConcatenating: transforms)
        values.append(NSValue(caTransform3D: CATransform3DIdentity))
        
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
        animation.duration = 0.25
        animation.repeatCount = HUGE
        animation.values = values
        
        return animation
    }
}

extension NSValue {
    
    class func values(byConcatenating caTransform3Ds: [CATransform3D]) -> [NSValue] {
        var nextTransform = CATransform3DIdentity
        
        var values = [NSValue(caTransform3D: nextTransform)]
        for transform in caTransform3Ds {
            nextTransform = CATransform3DConcat(nextTransform, transform)
            values.append(NSValue(caTransform3D: nextTransform))
        }

        return values
    }
}
