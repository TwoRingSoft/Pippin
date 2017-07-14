//
//  BugReportingController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/27/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import XCGLogger
import UIKit

struct BugReportingController {

    var logger: LogController?

    init() {
        logger?.logDebug(message: String(format: "[%@] Initializing bug reporter.", valueType(self)))
        // TODO: reimplement
        fatalError("not implemented")
    }

}

extension BugReportingController {

    func show(fromViewController viewController: UIViewController, screenshot: UIImage? = nil) {
        fatalError("not implemented")
    }

}
