//
//  Collection+Counts.swift
//  FastMath
//
//  Created by Andrew McKnight on 12/19/21.
//

import Foundation

public extension Collection {
    /// Count the number of elements that pass a test encapsulated in a specified block.
    func count(where: (Element) -> Bool) -> Int {
        filter(`where`).count
    }
}

public extension Collection where Element: Hashable {
    /// Return a dictionary keyed on unique elements in this collection mapped to the number of times it appears.
    var counts: [Element: Int] {
        reduce(into: [Element: Int]()) { (result, next) in
            result[next, default: 0] += 1
        }
    }
}
