//
//  Robot.swift
//  Anchorage
//
//  Created by Andrew McKnight on 10/14/19.
//

import XCTest

/// Protocol describing a UI testing robot following the pattern of the same name.
public protocol Robot {
    /// The currently foregrounded app under UI test.
    var app: XCUIApplication { get }
}

public extension Robot {
    var app: XCUIApplication {
        return XCUIApplication()
    }
}
