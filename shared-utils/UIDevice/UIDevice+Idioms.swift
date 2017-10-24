//
//  UIDevice+Idioms.swift
//  shared-utils
//
//  Created by Andrew McKnight on 3/14/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

extension UIDevice {

    class var isPhone: Bool {
        get {
            return current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        }
    }

}
