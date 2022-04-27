//
//  DefaultColors.swift
//  PippinCore
//
//  Created by Andrew McKnight on 12/12/19.
//

import UIKit

public struct DefaultColors: Colors {
    public init() {}

    public var background: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    public var foreground: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    public var foregroundSoft: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.gray
        }
    }
}
