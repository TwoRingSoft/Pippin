//
//  Error+NSError.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/9/19.
//

import Foundation

public protocol NSErrorConvertible {
    var code: Int { get }
    var nsError: NSError { get }
}
