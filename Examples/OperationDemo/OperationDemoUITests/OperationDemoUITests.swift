//
//  OperationDemoUITests.swift
//  OperationDemoUITests
//
//  Created by Andrew McKnight on 11/13/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import XCTest

class OperationDemoUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    /// Demonstrates what would happen with two synchronous operations executing asynchronous on a serial queue. The first operation's async work finishes after the second one begins. In real world scenarios, this could cause UI to display incorrectly or drop data.
    func testNaiveAsyncOperations() {
        let operationdemoWindow = XCUIApplication().windows["OperationDemo"]
        operationdemoWindow.buttons["Add Naive Async"].click()
        operationdemoWindow.buttons["Add Naive Async"].click()
        operationdemoWindow.buttons["►"].click()
    }
    
    /// Demonstrate the correct implementation of multiple async operations.
    func testActualAsyncOperations() {
        let operationdemoWindow = XCUIApplication().windows["OperationDemo"]
        operationdemoWindow.buttons["Add Async"].click()
        operationdemoWindow.buttons["Add Async"].click()
        operationdemoWindow.buttons["►"].click()
    }
    
    /// Demonstrate multiple serial execution of compound operations.
    func testCompoundOperations() {
        let operationdemoWindow = XCUIApplication().windows["OperationDemo"]
        operationdemoWindow.buttons["Add Compound"].click()
        operationdemoWindow.buttons["Add Compound"].click()
        operationdemoWindow.buttons["►"].click()
    }
    
    /// Ensures a compound operation cancels successfully and correctly and that the operaion queue continues operating subsequent operations.
    func testCompoundCancellation() {
        let operationdemoWindow = XCUIApplication().windows["OperationDemo"]
        operationdemoWindow.buttons["Add Compound"].click()
        operationdemoWindow.buttons["Add Sync"].click()
        operationdemoWindow.buttons["►"].click()
        operationdemoWindow.buttons["Cancel current"].click()
    }
}
