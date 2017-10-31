//
//  CrashReporter.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

public protocol CrashReporter {

    func initializeReporting()
    func log(message: String)
    func recordNonfatalError(error: Error, metadata: [String: Any]?)
    func setSessionMetadata(keysAndValues: [String: Any])

}
