//
//  PinpointKitAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import PinpointKit
import UIKit

public final class PinpointKitAdapter: NSObject {

    public var logger: Logger?

}

extension PinpointKitAdapter: BugReporter {

    public func show(fromViewController viewController: UIViewController, screenshot: UIImage? = nil) {
        // TODO: implement
    }

}
