//
//  UIEdgeInsets+Factory.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 8/9/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    init(all value: CGFloat) {
        self.top = value
        self.bottom = value
        self.left = value
        self.right = value
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.top = vertical
        self.bottom = vertical
        self.left = horizontal
        self.right = horizontal
    }

}
