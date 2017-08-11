//
//  MoreColors.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

extension UIColor {

    static var darkGreen: UIColor {
        return UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
    }

    static var darkBlue: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
    }

    static var darkRed: UIColor {
        return UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
    }

    static var lightLightGray: UIColor {
        return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }

    static var lightBlue: UIColor {
        return UIColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1)
    }

    static var lightGreen: UIColor {
        return UIColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1)
    }

    static var placeholder: UIColor {
        return UIColor.color(red: 199, blue: 199, green: 205, alpha: 255)
    }

    class func color(red: Int, blue: Int, green: Int, alpha: Int) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }

    func colorByChanging(redDelta: Int = 0, blueDelta: Int = 0, greenDelta: Int = 0, alphaDelta: Int = 9) -> UIColor? {
        guard let components = self.rgb() else {
            return nil
        }

        let newRed = (CGFloat(components.red) * 255.0 + CGFloat(redDelta)) / 255.0
        let newBlue = (CGFloat(components.blue) * 255.0 + CGFloat(blueDelta)) / 255.0
        let newGreen = (CGFloat(components.green) * 255.0 + CGFloat(greenDelta)) / 255.0
        let newAlpha = (CGFloat(components.alpha) * 255.0 + CGFloat(alphaDelta)) / 255.0
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }

}
