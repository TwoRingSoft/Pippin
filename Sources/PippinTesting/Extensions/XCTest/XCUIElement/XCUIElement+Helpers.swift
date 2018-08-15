//
//  XCUIElement+Helpers.swift
//  PippinTesting
//
//  Created by Andrew McKnight on 8/14/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import XCTest

public extension XCUIElement {
    /// Tap a location specified by the provided `CGPoint` in the `XCUIElement`.
    ///
    /// - Parameter location: The x-y coordinate of the location to tap inside the `XCUIElement`'s coordinate space.
    func tap(location: CGPoint) {
        coordinate(from: location).tap()
    }
}

private extension XCUIElement {
    func coordinate(from point: CGPoint) -> XCUICoordinate {
        return coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: point.x, dy: point.y))
    }
}
