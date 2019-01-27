//
//  Double+Random.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/3/18.
//

import Foundation

public extension Double {
    /// - Returns: a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
}
