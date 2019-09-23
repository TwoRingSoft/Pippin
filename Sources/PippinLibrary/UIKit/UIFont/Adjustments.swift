//
//  Adjustments.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/24/19.
//

import Foundation

public extension UIFont {
    /// - Returns: A new `UIFont` instance identical to the caller, but 25% smaller.
    var smaller: UIFont { return UIFont.maybeFont(ofFamily: self.fontName, size: self.pointSize * 0.75) }
    
    /// - Returns: A new `UIFont` instance identical to the caller, but 25% larger.
    var larger: UIFont { return UIFont.maybeFont(ofFamily: self.fontName, size: self.pointSize * 1.25) }
}
