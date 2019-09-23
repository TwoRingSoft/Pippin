//
//  UIView+Style.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/15/18.
//

import Foundation

public extension UIView {
    func roundCorners(radius: CGFloat = 15, borderWidth: CGFloat = 0, borderColor: CGColor = UIColor.lightLightGray.cgColor) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
