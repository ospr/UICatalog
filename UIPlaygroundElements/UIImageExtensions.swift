//
//  UIImageExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public convenience init?(named name: String, inBundleForObject object: AnyObject) {
        self.init(named: name, in: Bundle(for: type(of: object)), compatibleWith: nil)!
    }
}
