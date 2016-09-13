//
//  SequenceTypeExtensions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/31/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

// Taken from http://stackoverflow.com/a/33795713/4147791
extension Sequence {
    func findFirst(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
