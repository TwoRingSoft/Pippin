//
//  Error+NSError.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/9/19.
//

import Foundation

/// Protocol describing a way to convert a `Swift.Error` to an `NSError`.
public protocol NSErrorConvertible {
    /// The `Int` code that would appear in the analogous `NSError`.
    var code: Int { get }

    /// The `NSError` representation of this error.
    var nsError: NSError { get }
}
