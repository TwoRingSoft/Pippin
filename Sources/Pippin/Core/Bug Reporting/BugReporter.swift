//
//  BugReporter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import UIKit

/// `BugReporter` provides a common interface for working with a bug reporter object or SDK.
public protocol BugReporter: EnvironmentallyConscious {
    /// Initialize with an array of email addresses to which the bug report should be sent.
    init(recipients: [String])

    /// Display the bug reporting flow from a view controller instance, optionally with a screenshot, e.g. if you detect a screenshot, retrieve it, and use it for the bug report.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to display the flow from.
    ///   - screenshot: An optional image to use in the bug report.
    ///   - metadata: Optional dictionary with any extra data to send with the bug report, like logs/database.
    func show(fromViewController viewController: UIViewController, screenshot: UIImage?, metadata: [String: AnyObject]?)
}
