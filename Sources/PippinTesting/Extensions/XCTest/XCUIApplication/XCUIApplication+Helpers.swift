//
//  XCUIApplication+Helpers.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/8/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import XCTest

public extension XCUIApplication {
    func selectTableViewCell(containingText text: String) {
        tables.cells[text].tap()
    }
    
    func selectTabBarItem(withName name: String) {
        tabBars.buttons[name].tap()
    }
    
    func tapButton(withName name: String) {
        buttons[name].tap()
    }
    
    func enterWithOnscreenKeyboard(value: String) {
        for character in value {
            let characterValue = String(character)
            keys[characterValue].tap()
        }
    }
    
    /// Simulate a tap on the screen at a location relative to the screen boundaries.
    func tap(point: CGPoint) {
        windows.firstMatch.tap(location: point)
    }
}
