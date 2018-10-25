//
//  UIEdgeInsets+Factory.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 8/9/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    public init(all value: CGFloat) {
        self = UIEdgeInsets.init(top: value, left: value, bottom: value, right: value)
    }

    public init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self = UIEdgeInsets.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    public init(withTop top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self = UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
    }

    public func inset(topDelta: CGFloat = 0, leftDelta: CGFloat = 0, bottomDelta: CGFloat = 0, rightDelta: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + topDelta, left: left + leftDelta, bottom: bottom + bottomDelta, right: right + rightDelta)
    }

}
