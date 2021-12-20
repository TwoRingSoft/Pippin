//
//  Collection+Flatten.swift
//  FastMath
//
//  Created by Andrew McKnight on 12/18/21.
//

import Foundation

public extension Collection where Self.Index == Int, Element == [Any] {
    /// Reduce the dimensionality of an array by 1.
    var flattened: Element {
        reduce(Element()) { partialResult, next in
            partialResult + next
        }
    }
}
