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
// CrashReporter protocol body shared across platforms
// On iOS, also conforms to Debuggable (UIKit-dependent)

#if canImport(UIKit)
public protocol CrashReporter: EnvironmentallyConscious, Debuggable {
    init(serverKey: String, initialKeysAndValues: [String: String]?)
    func log(message: String)
    func recordNonfatalError(error: Error, metadata: [String: Any]?)
    func setSessionMetadata(keysAndValues: [String: Any])
    func testCrash()
}
#else
public protocol CrashReporter: EnvironmentallyConscious {
    init(serverKey: String, initialKeysAndValues: [String: String]?)
    func log(message: String)
    func recordNonfatalError(error: Error, metadata: [String: Any]?)
    func setSessionMetadata(keysAndValues: [String: Any])
    func testCrash()
}
#endif
