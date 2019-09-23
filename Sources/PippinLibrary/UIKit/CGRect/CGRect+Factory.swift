//
//  CGRect+Factory.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/12/19.
//

import CoreGraphics

public extension CGRect {
    /// Create a `CGRect` centered around a `CGPoint`.
    ///
    /// - Parameters
    ///   - point: The point on which the resulting `CGRect` will be centered.
    ///   - size: The size of the resulting `CGRect`.
    init(centeredAround point: CGPoint, with size: CGSize) {
        self = .init(origin: point.offset(xDelta: size.width / 2, yDelta: size.height / 2), size: size)
    }
}
