//
//  BugReportingController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/27/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

struct BugReportingController {

    var logger: LogController?

    init() {
        logger?.logDebug(message: String(format: "[%@] Initializing bug reporter.", valueType(self)))
        // TODO: reimplement
    }

}

extension BugReportingController {

    func show(fromViewController viewController: UIViewController, screenshot: UIImage? = nil) {
        if let screenshot = screenshot {

        } else {

        }
    }

}

extension BugReportingController: LogCollector {

    func retrieveLogs() -> [String] {
        guard let logContents = logger?.getLogContents() else {
            return []
        }

        return [ logContents ]
    }

}
