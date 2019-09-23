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

    case touchVisualizer = 1
    case debugging = 2
    case indicator = 3
    case alerter = 4
    
    public func windowLevel() -> UIWindow.Level {
        return UIWindow.Level(rawValue: rawValue)
    }
}
