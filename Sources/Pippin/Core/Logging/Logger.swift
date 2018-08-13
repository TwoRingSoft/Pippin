//
//  Logger.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/// `Error` enum of errors a logger may encounter.
enum LoggerError: Swift.Error {
    /// No file could be located, or no URL was supplied.
    case noLoggingFile(String)

    /// Logging file exists and is locatable but could not be read.
    case couldNotReadLogFile(String, NSError)
}

/// Protocol declaring that conformers provide a property to store a reference to an object conforming to the `Logger` protocol. The property is left optional to ease setup for e.g. testing.
public protocol Loggable {
    /// An instance conforming to the `Logger` protocol to be used internally in components conformin to `Loggable`.
    var logger: Logger? { get set }
}

/// `Logger` provides a common interface to logging mechanisms.
public protocol Logger {
    /// The current log level the instance operates at.
    var logLevel: LogLevel { get set }

    /// Optional reference to a `CrashReporter` instance, to help automatically record log messages to the reporter's breadcrumb log.
    var crashReporter: CrashReporter? { get set }

    /// Log a message at the verbose level.
    /// - parameter message: The message to log at verbose level.
    func logVerbose(message: String)

    /// Log a message at the debug level.
    /// - parameter message: The message to log at debug level.
    func logDebug(message: String)

    /// Log a message at the info level.
    /// - parameter message: The message to log at info level.
    func logInfo(message: String)

    /// Log a message at the warning level.
    /// - parameter message: The message to log at warning level.
    func logWarning(message: String)

    /// Log a message at the error level.
    ///
    /// - Parameters:
    ///   - message: The message to log at error level.
    ///   - error: The associated error object to log.
    func logError(message: String, error: Error)

    /// Return all contents of logs written since logs were created or last wiped.
    func logContents() -> String?

    /// Wipe all persisted logs.
    func resetLogs()
}
