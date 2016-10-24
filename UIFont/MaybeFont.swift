//
//  MaybeFont.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/1/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

extension UIFont {

    /// - returns: either the UIFont defined by the family string provided, or the system font of the same size
    static func maybeFont(ofFamily family: String, size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: family, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }

}
