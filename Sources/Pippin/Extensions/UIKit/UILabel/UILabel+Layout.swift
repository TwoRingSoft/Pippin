//
//  UILabel+Layout.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/6/17.
//

import UIKit

extension UILabel {

    public func allowShrinking(downTo minimumScale: CGFloat, withTightening: Bool) {
        allowsDefaultTighteningForTruncation = withTightening
        minimumScaleFactor = minimumScale
        adjustsFontSizeToFitWidth = true
    }

}
