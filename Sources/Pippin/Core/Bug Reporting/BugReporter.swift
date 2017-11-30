//
//  BugReporter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

/**
 `BugReporter` provides a common interface for working with a bug reporter object or SDK.
 */
public protocol BugReporter {

    /**
     An instance conforming to `Logger` may be supplied for use by instances conforming to `BugReporter`.
     */
    var logger: Logger? { get set }

    /**
     Display the bug reporting flow from a view controller instance, optionally with a screenshot, e.g. if you detect a screenshot, retrieve it, and use it for the bug report.
     - parameters:
         - viewController: the view controller to display the flow from
         - screenshot: an optional image to use in the bug report
     */
    func show(fromViewController viewController: UIViewController, screenshot: UIImage?)

}
