//
//  PinpointKitAdapter.swift
//  Dough
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import PinpointKit
import UIKit

final class PinpointKitAdapter {

    var logger: Logger?

}

extension PinpointKitAdapter: BugReporter {

    func show(fromViewController viewController: UIViewController, screenshot: UIImage? = nil) {
        // TODO: implement
    }

}
