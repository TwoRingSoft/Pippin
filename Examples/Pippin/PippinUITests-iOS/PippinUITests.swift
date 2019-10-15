//
//  PippinUITests.swift
//  PippinUITests
//
//  Created by Andrew McKnight on 9/23/18.
//

import XCTest

class PippinUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testExample() {
        UITestRobot()
            .incrementOnce()
            .incrementAFewTimes()
    }
    
}
