//
//  MathExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/12/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

func log2orZero(_ d: CGFloat) -> CGFloat {
    return d <= 0 ? 0 : log2(d)
}
