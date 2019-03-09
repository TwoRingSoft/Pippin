//
//  WindowLevel.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/20/18.
//

import Foundation

/// `enum` defining the `CGFloat` offsets to be added to the `UIWindowLevelAlert` level of the respective component's display `UIWindow`.
/// 
public enum WindowLevel: CGFloat {
    static let `default` = UIWindow.Level.statusBar

    case debugging = 1
    case indicator = 2
    case alerter = 3
    
    public func windowLevel() -> UIWindow.Level {
        return WindowLevel.`default`
    }
}
