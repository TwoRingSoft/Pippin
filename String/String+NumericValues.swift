//
//  String+NumericValues.swift
//  shared-utils
//
//  Created by Andrew McKnight on 12/18/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

extension String {

    var doubleValue: Double {
        return (self as NSString).doubleValue
    }

    var intValue: Int {
        return (self as NSString).integerValue
    }

}
