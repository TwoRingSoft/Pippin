//
//  Array+Search.swift
//  Trigonometry
//
//  Created by Andrew McKnight on 3/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {

    /**
     - precondition: array must be sorted
     - returns: the position of the query in the array
     */
    func binarySearchRecursive(lowIdx: Int, highIdx: Int, query: Element) -> Int? {
        if lowIdx >= highIdx {
            return nil
        }

        let midIdx = lowIdx + (highIdx - lowIdx) / 2

        if self[midIdx] > query {
            return binarySearchRecursive(lowIdx: lowIdx, highIdx: midIdx, query: query)
        } else if self[midIdx] < query {
            return binarySearchRecursive(lowIdx: midIdx + 1, highIdx: highIdx, query: query)
        } else {
            return midIdx
        }
    }

}

extension Array where Element: IntegerArithmetic {

    /**
     - precondition: array must be sorted
     - returns: the position of the value nearest to query in the array
     */
    func fuzzyBinarySearchRecursive(lowIdx: Int, highIdx: Int, query: Element) -> Int {
        if lowIdx == highIdx - 1 {
            // we're in between two elements. pick the one that's closer in value
            let a = self[lowIdx]
            let b = self[highIdx]
            let closerToA = query - a < b - query
            return closerToA ? lowIdx : highIdx
        }

        let midIdx = lowIdx + (highIdx - lowIdx) / 2

        if self[midIdx] > query {
            return fuzzyBinarySearchRecursive(lowIdx: lowIdx, highIdx: midIdx, query: query)
        } else if self[midIdx] < query {
            return fuzzyBinarySearchRecursive(lowIdx: midIdx + 1, highIdx: highIdx, query: query)
        } else {
            return midIdx
        }
    }

}
