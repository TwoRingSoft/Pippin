//
//  Array+Search.swift
//  Trigonometry
//
//  Created by Andrew McKnight on 3/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

extension Array where Element: Strideable {

    /**
     - precondition: array must be sorted.
     - parameters:
         - lowerBound: defaults to 0.
         - upperBound: defaults to `nil`, meaning the last element in the array.
         - query: value for which to search.
     - returns: the position of the query in the array or `nil` if it doesn't exist in the array.
     */
    func binarySearchRecursive(lowerBound: Int = 0, upperBound: Int? = nil, query: Element) -> Int? {
        let resolvedUpperBound = upperBound ?? count - 1

        if lowerBound >= resolvedUpperBound {
            return nil
        }

        let midIdx = lowerBound + (resolvedUpperBound - lowerBound) / 2

        if self[midIdx] > query {
            return binarySearchRecursive(lowerBound: lowerBound, upperBound: midIdx, query: query)
        } else if self[midIdx] < query {
            return binarySearchRecursive(lowerBound: midIdx + 1, upperBound: resolvedUpperBound, query: query)
        } else {
            return midIdx
        }
    }

    /**
     Find the index of the element in this array that is closest to the query value. If `query` falls directly between two values, the lesser is chosen.
     - precondition: array must be sorted.
     - parameters:
         - lowerBound: defaults to 0.
         - upperBound: defaults to `nil`, meaning the last element in the array.
         - query: value for which to search.
     - returns: the position of the value nearest to query in the array.
     */
    func fuzzyBinarySearchRecursive(lowerBound: Int = 0, upperBound: Int? = nil, query: Element) -> Int {
        let resolvedUpperBound = upperBound ?? count - 1

        if lowerBound == resolvedUpperBound {
            return lowerBound
        }

        if lowerBound == resolvedUpperBound - 1 {
            // we're in between two elements. pick the one that's closer in value
            let a = self[lowerBound]
            let b = self[resolvedUpperBound]
            let closerToA = query - a < b - query
            return closerToA ? lowerBound : resolvedUpperBound
        }

        let midIdx = lowerBound + (resolvedUpperBound - lowerBound) / 2

        let a = self[midIdx]
        let b = self[midIdx + 1]
        if query - a < b - query {
            return fuzzyBinarySearchRecursive(lowerBound: lowerBound, upperBound: midIdx, query: query)
        } else {
            return fuzzyBinarySearchRecursive(lowerBound: midIdx + 1, upperBound: resolvedUpperBound, query: query)
        }
    }

}
