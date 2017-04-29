//
//  BugReportingController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/27/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit
import PinpointKit

struct BugReportingController {

    var pinpointKit: PinpointKit!
    var logger: LogController?

    init() {
        logger?.logDebug(message: String(format: "[%@] Initializing PinpointKit.", valueType(self)))
        let feedbackConfig = FeedbackConfiguration(recipients: [ String(format: "andrew+%@@tworingsoft.com", Bundle.getAppName()) ])
        let config = Configuration(logCollector: self, feedbackConfiguration: feedbackConfig)
        pinpointKit = PinpointKit(configuration: config)
    }

}

extension BugReportingController {

    func show(fromViewController viewController: UIViewController) {
        pinpointKit.show(from: viewController)
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
