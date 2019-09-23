//
//  UIColor+Factory.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/3/17.
//

import UIKit

public extension UIColor {

    /// Construct a `UIColor` using integer values in `[0,255]`.
    ///
    /// - Parameters: red, blue, green, alpha
    /// - Returns: a `UIColor` with the specified rgba components.
    class func color(red: Int, blue: Int, green: Int, alpha: Int) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }

    /// Construct a new color by shifting this color's red, green, blue and alpha values by a value in `[0,255]`.
    ///
    /// - Parameters: redDelta, blueDelta, greenDelta, alphaDelta
    /// - Returns: New `UIColor` with the rgba components adjusted using the original color and parameter amounts.
    func colorByChanging(redDelta: Int = 0, blueDelta: Int = 0, greenDelta: Int = 0, alphaDelta: Int = 0) -> UIColor? {
        guard let components = self.rgb() else {
            return nil
        }

        let newRed = (CGFloat(components.red) * 255.0 + CGFloat(redDelta)) / 255.0
        let newBlue = (CGFloat(components.blue) * 255.0 + CGFloat(blueDelta)) / 255.0
        let newGreen = (CGFloat(components.green) * 255.0 + CGFloat(greenDelta)) / 255.0
        let newAlpha = (CGFloat(components.alpha) * 255.0 + CGFloat(alphaDelta)) / 255.0
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }

    /// Scale the values of the components of the calling `UIColor`.
    ///
    /// - Parameters: redScale, greenScale, blueScale, alphaScale
    /// - Returns: The new `UIColor` with the caller's rgba components scaled by the parameters.
    func colorByScaling(red redScale: CGFloat = 1, green greenScale: CGFloat = 1, blue blueScale: CGFloat = 1, alpha alphaScale: CGFloat = 1 ) -> UIColor? {
        guard let components = self.rgb() else {
            return nil
        }

        let newRed = CGFloat(components.red) * redScale
        let newBlue = CGFloat(components.blue) * blueScale
        let newGreen = CGFloat(components.green) * greenScale
        let newAlpha = CGFloat(components.alpha) * alphaScale
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }

}

