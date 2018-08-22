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
        self = UIEdgeInsetsMake(value, value, value, value)
    }

    public init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self = UIEdgeInsetsMake(vertical, horizontal, vertical, horizontal)
    }
    
    public init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self = UIEdgeInsetsMake(top, left, bottom, right)
    }

    public func inset(topDelta: CGFloat = 0, leftDelta: CGFloat = 0, bottomDelta: CGFloat = 0, rightDelta: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + topDelta, left: left + leftDelta, bottom: bottom + bottomDelta, right: right + rightDelta)
    }

}
