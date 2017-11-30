//
//  CrashReporter.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/**
 `CrashReporter` provides a common interface for working with crash reporter
 objects or SDKs.
 */
public protocol CrashReporter {

    /**
     Start the crash reporter session.
     */
    func initializeReporting()

    /**
     Log a message to the crash reporter's breadcrumb log.
     - parameter message: the message to write to the log
     */
    func log(message: String)

    /**
     Record the stack trace for a nonfatal error during execution, typically when
     an error object is unexpectedly returned from an Apple or 3rd party API.
     - parameters:
         - error: the error object to record
         - metadata: any extra data to record with the error
     */
    func recordNonfatalError(error: Error, metadata: [String: Any]?)

    /**
     Record metadata to store with the session to help filter crash reports.
     - parameter keysAndValues: the metadata to record as a dictionary
     */
    func setSessionMetadata(keysAndValues: [String: Any])

    /**
     Crash the application.
     */
    func testCrash()

}
