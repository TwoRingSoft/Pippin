//
//  LogLevel.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation
import PippinLibrary

/**
 Enumeration of logging levels.
 */
public enum LogLevel: Int {

    /**
     A value was supplied that doesn't correspond to a known logging level.
     */
    case unknown = 0

    /**
     Logging level for large amounts of data, for dumping memory and data structures.
     */
    case verbose

    /**
     Logging Level for debugging execution, like tracing code paths.
     */
    case debug

    /**
     Logging level for general information about usage of the app.
     */
    case info

    /**
     Logging level to point out bad code behavior that doesn't impede app UX.
     */
    case warning

    /**
     Logging level to record an error that will affect app UX.
     */
    case error

}

/**
 Adopt `CustomDebugStringConvertible` to convert between debug description strings and `LogLevel` cases.
 */
extension LogLevel: CustomDebugStringConvertible {

    /**
     The debugging description for the log level. A reverse-DNS style string.
     */
    public var debugDescription: String {
        get {
            return String(asRDNSForCurrentAppWithSubpaths: [ "log-level", description ])
        }
    }

    /**
     Construct a `LogLevel` case from a debug description.
     - returns: the corresponding `LogLevel` case, or `nil` if none match.
     - Note: This isn't actually a function in `CustomdebugStringConvertible` but it's provided for consistent API. It is a failable initializer just like its counterpart.
     */
    public init?(debugDescription: String?) {
        guard let debugDescription = debugDescription else { return nil }
        
        if debugDescription == String(reflecting: LogLevel.unknown) {
            self = .unknown
        } else if debugDescription == String(reflecting: LogLevel.verbose) {
            self = .verbose
        } else if debugDescription == String(reflecting: LogLevel.debug) {
            self = .debug
        } else if debugDescription == String(reflecting: LogLevel.info) {
            self = .info
        } else if debugDescription == String(reflecting: LogLevel.warning) {
            self = .warning
        } else if debugDescription == String(reflecting: LogLevel.error) {
            self = .error
        } else {
            return nil
        }
    }

}


/**
 Adopt `CustomStringConvertible` to convert between description strings and `LogLevel` cases.
 */
extension LogLevel: CustomStringConvertible {

    /**
     The description for the log level.
     */
    public var description: String {
        get {
            switch self {
            case .unknown: return "unknown"
            case .verbose: return "verbose"
            case .debug: return "debug"
            case .info: return "info"
            case .warning: return "warning"
            case .error: return "error"
            }
        }
    }

    /**
     Construct a `LogLevel` case from a description.
     - returns: the corresponding `LogLevel` case, or `nil` if none match.
     */
    public init?(_ description: String) {
        if description == String(describing: LogLevel.unknown) {
            self = .unknown
        } else if description == String(describing: LogLevel.verbose) {
            self = .verbose
        } else if description == String(describing: LogLevel.debug) {
            self = .debug
        } else if description == String(describing: LogLevel.info) {
            self = .info
        } else if description == String(describing: LogLevel.warning) {
            self = .warning
        } else if description == String(describing: LogLevel.error) {
            self = .error
        } else {
            return nil
        }
    }

}
