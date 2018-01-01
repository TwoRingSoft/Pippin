//
//  UIScreen+HairlineWidth.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/5/17.
//

import UIKit

extension UIScreen {

    public var hairlineWidth: CGFloat {
        if scale > 0 {
            return 1 / scale
        } else {
            return 1
        }
    }

}
