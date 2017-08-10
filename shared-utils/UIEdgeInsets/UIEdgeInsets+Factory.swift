//
//  UIEdgeInsets+Factory.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 8/9/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    init(allEqualling value: CGFloat) {
        self.top = value
        self.bottom = value
        self.left = value
        self.right = value
    }

}
