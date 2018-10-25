//
//  DebugWindow.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/30/17.
//

import Foundation

class DebugWindow: UIWindow {
    
    var menuDisplayed: Bool = false

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event) else { return nil }
        
        // if the menu is displayed, let `hitTest` behave as it usually would. if the menu isn't displayed, we'll go on to passing through touches not on the debugging button
        guard !menuDisplayed else { return result }

        // if the button was not tapped, return `nil` to continue reaching down
        // the hierarchy to the app window
        if !result.isKind(of: UIButton.self) {
            return nil
        }

        // otherwise, return the button so it can respond to taps/gestures
        return result
    }

}
