//
//  AppMonitor.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/**
 `AppMonitor` provides a common interface for working with app monitoring
 objects or SDKs: crash reporting, nonfatal errors, logs and breadcrumbs.
 */
// AppMonitor protocol body shared across platforms
// On iOS, also conforms to Debuggable (UIKit-dependent)

#if canImport(UIKit)
public protocol AppMonitor: EnvironmentallyConscious, Debuggable {
    init(serverKey: String, initialKeysAndValues: [String: String]?)

    /// Whether the service supports unstructured log messages (e.g. Sentry Logs).
    var supportsLogs: Bool { get }

    /// Whether the service supports breadcrumbs for contextual trail.
    var supportsBreadcrumbs: Bool { get }

    /// Record an unstructured log message. Only called if `supportsLogs` is true.
    func log(message: String)

    /// Record a breadcrumb for contextual trail. Only called if `supportsBreadcrumbs` is true.
    func recordBreadcrumb(message: String, category: String, level: LogLevel)

    func recordNonfatalError(error: Error, metadata: [String: Any]?)
    func setSessionMetadata(keysAndValues: [String: Any])
    func setUser(id: String?, username: String?, email: String?)
    func testCrash()
}
#else
public protocol AppMonitor: EnvironmentallyConscious {
    init(serverKey: String, initialKeysAndValues: [String: String]?)

    var supportsLogs: Bool { get }
    var supportsBreadcrumbs: Bool { get }

    func log(message: String)
    func recordBreadcrumb(message: String, category: String, level: LogLevel)
    func recordNonfatalError(error: Error, metadata: [String: Any]?)
    func setSessionMetadata(keysAndValues: [String: Any])
    func setUser(id: String?, username: String?, email: String?)
    func testCrash()
}
#endif

@available(*, deprecated, renamed: "AppMonitor")
public typealias CrashReporter = AppMonitor
