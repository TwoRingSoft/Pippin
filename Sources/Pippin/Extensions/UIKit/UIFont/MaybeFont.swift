//
//  MaybeFont.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/1/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public extension UIFont {
    /// - parameters:
    /// - family: the custom font family to use, if possible
    /// - size: size of the font
    /// - boldFont: if `true` and the custom font can't be loaded, construct the system font using `UIFont.boldSystemFont`; uses `UIFont.systemFont` otherwise
    /// - returns: either the UIFont defined by the family string provided, or the system font of the same size
    static func maybeFont(ofFamily family: String, size: CGFloat, boldFont: Bool = false) -> UIFont {
        if let font = UIFont.init(name: family, size: size) {
            return font
        } else {
            if boldFont {
                return UIFont.boldSystemFont(ofSize: size)
            } else {
                return UIFont.systemFont(ofSize: size)
            }
        }
    }
}
