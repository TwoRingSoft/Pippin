//
//  Logger.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

/// `Error` enum of errors a logger may encounter.
public enum LoggerError: Swift.Error {
    /// No file could be located, or no URL was supplied.
    case noLoggingFile(String)

    /// Logging file exists and is locatable but could not be read.
    case couldNotReadLogFile(String, NSError)
}

#if canImport(UIKit)
public protocol Logger: EnvironmentallyConscious, Debuggable {
    var logLevel: LogLevel { get set }
    func logVerbose(message: String)
    func logDebug(message: String)
    func logInfo(message: String)
    func logWarning(message: String)
    func logError(message: String, error: Error)
    func logContents() -> String?
    func resetLogs()
}
#else
public protocol Logger: EnvironmentallyConscious {
    var logLevel: LogLevel { get set }
    func logVerbose(message: String)
    func logDebug(message: String)
    func logInfo(message: String)
    func logWarning(message: String)
    func logError(message: String, error: Error)
    func logContents() -> String?
    func resetLogs()
}
#endif
