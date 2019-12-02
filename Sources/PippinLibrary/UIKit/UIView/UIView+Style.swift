//
//  UIView+Style.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/15/18.
//

import Foundation

public extension UIView {
    @objc func objc_roundCorners(radius: CGFloat, borderWidth: CGFloat, borderColor: CGColor) {
        roundCorners(radius: radius, borderWidth: borderWidth, borderColor: borderColor)
    }

    func roundCorners(radius: CGFloat = 15, borderWidth: CGFloat = 0, borderColor: CGColor = UIColor.lightLightGray.cgColor) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
