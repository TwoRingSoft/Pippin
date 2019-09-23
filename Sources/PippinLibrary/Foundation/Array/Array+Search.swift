//
//  Array+Search.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

public extension Array where Element: Strideable {

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

        if lowerBound == resolvedUpperBound {
            if query != self[lowerBound] {
                return nil
            }
            return lowerBound
        }

        if lowerBound > resolvedUpperBound {
            return nil
        }

        let midIdx = lowerBound + (resolvedUpperBound - lowerBound) / 2
        let midValue = self[midIdx]

        if midValue > query {
            return binarySearchRecursive(lowerBound: lowerBound, upperBound: midIdx, query: query)
        } else if midValue < query {
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
            // we're in between two elements. pick the one that's closer in value, or the lower if equidistant
            let a = self[lowerBound]
            let b = self[resolvedUpperBound]
            let diffA = a.distance(to: query)
            let diffB = query.distance(to: b)
            if diffA == diffB {
                return lowerBound
            }
            let closerToA = diffA < diffB
            return closerToA ? lowerBound : resolvedUpperBound
        }

        let midIdx = lowerBound + (resolvedUpperBound - lowerBound) / 2

        let midValue = self[midIdx]
        let midNeighborValue = self[midIdx + 1]
        let diffMidA = midValue.distance(to: query)
        let diffMidB = query.distance(to: midNeighborValue)
        if query > midValue && diffMidA > diffMidB {
            return fuzzyBinarySearchRecursive(lowerBound: midIdx + 1, upperBound: resolvedUpperBound, query: query)
        } else   {
            return fuzzyBinarySearchRecursive(lowerBound: lowerBound, upperBound: midIdx, query: query)
        }
    }

}
