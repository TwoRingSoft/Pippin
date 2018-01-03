//
//  Int+Random.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/3/18.
//

import Foundation

extension Int {

    /**
     - Parameters:
        - min: the lower bound on the random number to generate, must be ≥ 0, which is its default value.
        - max: the upper bound on the random number, must be strictly larget than `min`.
     - Warning: supplying `min` < 0 or `max` ≤ `min` results in a fatal error.
     - Returns: random integer between `min` and `max`
     */
    public static func random(min: Int = 0, max: Int) -> Int {
        precondition(min >= 0 && min < max)
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }

}
