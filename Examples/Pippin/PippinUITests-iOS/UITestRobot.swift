//
//  UITestRobot.swift
//  PippinUITests-iOS
//
//  Created by Andrew McKnight on 10/14/19.
//

import PippinTesting
import XCTest

final class UITestRobot: NSObject, Robot {
    @discardableResult func incrementAFewTimes() -> Self {
        for _ in 1..<5 {
            tapTheButton()
        }
        return self
    }

    @discardableResult func incrementOnce() -> Self {
        tapTheButton()
        return self
    }

    private func tapTheButton() {
        app.buttons["Increment"].tap()
    }
}
