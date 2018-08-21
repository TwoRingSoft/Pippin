//
//  WindowLevel.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/20/18.
//

import Foundation

/// `enum` defining the `CGFloat` offsets to be added to the `UIWindowLevelAlert` level of the respective component's display `UIWindow`.
enum WindowLevel: CGFloat {
    case debugging = 1
    case indicator = 2
    case alerter = 3
    
    func windowLevel() -> CGFloat {
        return UIWindowLevelAlert + self.rawValue
    }
}
