//
//  BugReporter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

public protocol BugReporter {

    var logger: Logger? { get set }
    func show(fromViewController viewController: UIViewController, screenshot: UIImage?)

}
