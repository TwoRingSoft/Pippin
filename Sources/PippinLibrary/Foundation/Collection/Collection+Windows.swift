//
//  Collection+Windows.swift
//  FastMath
//
//  Created by Andrew McKnight on 12/18/21.
//

import Foundation

public extension Collection where Self.Index == Int {
    /// Given an array, return an array of arrays that are each a window of values from the original array
    /// of the specified size. For example, `[1, 2, 3, 4, 5]` with window size of `3` yields
    /// `[[1, 2, 3], [2, 3, 4], [3, 4, 5]]`.
    func windows(ofSize size: Int) -> [[Element]] {
        var windows = [[Element]]()
        for i in 0 ... count - size {
            var window = [Element]()
            for j in 0 ..< size {
                let x = i + j
                window.append(self[x])
            }
            windows.append(window)
        }
        return windows
    }

    /// Given an array, return an array of 2-tuples consisting of continuous pairs of elements. E.g
    /// `[1, 2, 3]` yields `[(1, 2), (2, 3)]`.
    var pairs: [(a: Element, b: Element)] {
        windows(ofSize: 2).map { ($0[0], $0[1]) }
    }
}
