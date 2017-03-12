//
//  Array+Search.swift
//  Trigonometry
//
//  Created by Andrew McKnight on 3/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

extension Array {

    /**
     - precondition: array must be sorted
     */
    func indexOfClosestSorted<T: FloatingPoint>(toValue value: T) -> Int {
        var smallestDifference = last! as! T
        var closestIntervalAngleIdx = 0
        for i in 0 ..< count {
            let closestValueCandidate = self[i] as! T
            var difference = fabs(closestValueCandidate - value)

            if difference == 0 {
                return i
            }

            if difference < 0 {
                difference *= -1
            }

            if difference < smallestDifference {
                smallestDifference = difference
                closestIntervalAngleIdx = i
            }
        }
        return closestIntervalAngleIdx
    }
    
}
