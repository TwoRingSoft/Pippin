//
//  ColorComponents.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

public extension UIColor {

    /**
     - returns: `nil` if the values couldn't be extracted from the color, or a
     tuple with labeled members `red`, `green`, `blue` and `alpha` with values
     in `[0,1]`.
     */
    func rgb() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (red:fRed, green:fGreen, blue:fBlue, alpha:fAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
