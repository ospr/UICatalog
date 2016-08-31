//
//  SequenceTypeExtensions.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/31/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

// Taken from http://stackoverflow.com/a/33795713/4147791
extension SequenceType {
    func findFirst(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
