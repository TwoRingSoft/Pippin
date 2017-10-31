//
//  XCGLoggerAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/28/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation
import XCGLogger

extension LogLevel {

    func xcgLogLevel() -> XCGLogger.Level {
        switch self {
        case .unknown: return XCGLogger.Level.info // default to info
        case .verbose: return XCGLogger.Level.verbose
        case .debug: return XCGLogger.Level.debug
        case .info: return XCGLogger.Level.info
        case .warning: return XCGLogger.Level.warning
        case .error: return XCGLogger.Level.error
        }
    }

    init(xcgLevel: XCGLogger.Level) {
        switch xcgLevel {
        case .verbose: self = .verbose
        case .debug: self = .debug
        case .info: self = .info
        case .warning: self = .warning
        case .error: self = .error
        case .severe: self = .error
        case .none: self = .info // default to info
        }
    }

}

public final class XCGLoggerAdapter: NSObject {

    fileprivate var _logLevel: LogLevel = .info
    fileprivate var _crashReporter: CrashReporter? = nil
    fileprivate var loggingQueue: DispatchQueue!
    fileprivate var logFileURL: URL?
    fileprivate var xcgLogger = XCGLogger(identifier: XCGLogger.Constants.fileDestinationIdentifier, includeDefaultDestinations: true)

    public init(name: String, logLevel: LogLevel) {
        super.init()
        let appName = Bundle.getAppName()
        self.loggingQueue = DispatchQueue(label: "com.tworingsoft.\(appName).logger.\(name).queue")

        guard let logFileURL = urlForFilename(fileName: "\(appName)-\(name).log", inDirectoryType: .libraryDirectory) else {
            reportMissingLogFile()
            return
        }
        self.logFileURL = logFileURL

        self.logLevel = logLevel

        xcgLogger.setup(level: logLevel.xcgLogLevel(),
                        showLogIdentifier: false,
                        showFunctionName: false,
                        showThreadName: false,
                        showLevel: true,
                        showFileNames: false,
                        showLineNumbers: false,
                        showDate: true,
                        writeToFile: logFileURL,
                        fileLevel: logLevel.xcgLogLevel()
        )
    }

}

// MARK: Logger
extension XCGLoggerAdapter: Logger {

    public var logLevel: LogLevel {
        get {
            return _logLevel
        }
        set(newValue) {
            _logLevel = newValue
            xcgLogger.outputLevel = newValue.xcgLogLevel()
        }
    }

    public var crashReporter: CrashReporter? {
        get {
            return _crashReporter
        }
        set(newValue) {
            _crashReporter = newValue
        }
    }

    public func logDebug(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.debug)
    }

    public func logInfo(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.info)
    }

    public func logWarning(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.warning)
    }

    public func logVerbose(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.verbose)
    }

    public func logError(message: String, error: Error) {
        let messageWithErrorDescription = String(format: "%@: %@", message, error as NSError)
        self.log(message: messageWithErrorDescription, logLevel: XCGLogger.Level.error)
        crashReporter?.recordNonfatalError(error: error, metadata: nil)
    }

    public func logContents() -> String? {
        var logContentsString = String()

        if let logContents = getContentsOfLog() {
            logContentsString.append(logContents)
            logContentsString.append("\n")
        }

        return logContentsString
    }

    public func resetLogs() {
        resetContentsOfLog()
    }

}

// MARK: Private
private extension XCGLoggerAdapter {

    func resetContentsOfLog() {
        guard let logFileURL = logFileURL else {
            reportMissingLogFile()
            return
        }
        do {
            try FileManager.default.removeItem(at: logFileURL)
        } catch {
            logError(message: String(format: "[%@] failed to delete log file at %@", instanceType(self), logFileURL.absoluteString), error: error)
        }
    }

    func getContentsOfLog() -> String? {
        var contents: String?
        do {
            if let logFileURL = logFileURL {
                contents = try String(contentsOf: logFileURL, encoding: .utf8)
            }
        } catch {
            logError(message: String(format: "[%@] Could not read logging file: %@.", instanceType(self), error as NSError), error: error)
        }
        return contents
    }

    func log(message: String, logLevel: XCGLogger.Level) {
        loggingQueue.async {
            self.xcgLogger.logln(message, level: logLevel)
        }
        if self.logLevel.xcgLogLevel() >= logLevel {
            crashReporter?.log(message: String(format: "[%@] %@", logLevel.description, message))
        }
    }

    func reportMissingLogFile() {
        logError(message: String(format: "[%@] Could not locate log file.", instanceType(self)), error: LoggerError.noLoggingFile("Could not locate log file."))
    }

    private func urlForFilename(fileName: String, inDirectoryType directoryType: FileManager.SearchPathDirectory) -> URL? {
        return FileManager.default.urls(for: directoryType, in: .userDomainMask).last?.appendingPathComponent(fileName)
    }
    
}
