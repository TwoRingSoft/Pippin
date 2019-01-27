//
//  MoreColors.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

public extension UIColor {
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
}
