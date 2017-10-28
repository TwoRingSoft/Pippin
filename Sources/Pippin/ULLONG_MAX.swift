//
//  ULLONG_MAX.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/// ULLONG_MAX is not currently defined in Swift.
let ULLONG_MAX = UInt64(2) * UInt64(LLONG_MAX) + UInt64(1)
