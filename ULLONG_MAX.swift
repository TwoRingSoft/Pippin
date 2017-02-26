//
//  ULLONG_MAX.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/// ULLONG_MAX is not currently defined in Swift.
let ULLONG_MAX = UInt(2) * UInt(LLONG_MAX) + UInt(1)
