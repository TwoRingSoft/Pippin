//
//  LogController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 1/28/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Crashlytics
import Foundation
import XCGLogger

enum LogLevel: Int {

    case unknown = 0
    case verbose
    case debug
    case info
    case warning
    case error

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

}

final class LogController: NSObject {

    var logLevel: LogLevel = .info
    fileprivate var loggingQueue: DispatchQueue!
    fileprivate var logFileURL: URL?
    fileprivate let xcgLogger = XCGLogger(identifier: XCGLogger.Constants.fileDestinationIdentifier, includeDefaultDestinations: true)

    init(name: String, logLevel: LogLevel) {
        super.init()
        let appName = Bundle.getAppName()
        self.loggingQueue = DispatchQueue(label: "com.tworingsoft.\(appName).logger.\(name).queue")

        guard let logFileURL = urlForFilename(fileName: "\(appName)-\(name).log", inDirectoryType: .libraryDirectory) else {
            reportMissingLogFile()
            return
        }
        self.logFileURL = logFileURL

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

    private func urlForFilename(fileName: String, inDirectoryType directoryType: FileManager.SearchPathDirectory) -> URL? {
        return FileManager.default.urls(for: directoryType, in: .userDomainMask).last?.appendingPathComponent(fileName)
    }

}

// MARK: Public
extension LogController {

    func setLoggingLevel(newLevel: XCGLogger.Level) {
        xcgLogger.outputLevel = newLevel
    }

    /**
     - returns: contents of all log files
     */
    func getLogContents() -> String? {
        var logContentsString = String()

        if let logContents = getContentsOfLog() {
            logContentsString.append(logContents)
            logContentsString.append("\n")
        }

        return logContentsString
    }

    func resetLogs() {
        resetContentsOfLog()
    }

}

// MARK: Logging
extension LogController {

    func logDebug(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.debug)
    }

    func logInfo(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.info)
    }

    func logWarning(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.warning)
    }

    func logVerbose(message: String) {
        self.log(message: message, logLevel: XCGLogger.Level.verbose)
    }

    func logError(message: String, error: Error) {
        let messageWithErrorDescription = String(format: "%@: %@", message, error as NSError)
        self.log(message: messageWithErrorDescription, logLevel: XCGLogger.Level.error)
        Crashlytics.sharedInstance().recordError(error as NSError)
    }

}

// MARK: Private
private extension LogController {

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
            let message = String(format: "[%@] Could not read logging file.", instanceType(self))
            let wrappedError = LoggingErrorCode.CouldNotReadLogFile.error(withDescription: message, userInfo: [ NSUnderlyingErrorKey: error as NSError ])
            logError(message: message, error: wrappedError)
        }
        return contents
    }

    func log(message: String, logLevel: XCGLogger.Level) {
        loggingQueue.async {
            self.xcgLogger.logln(message, level: logLevel)
        }

        DispatchQueue.main.async {
            withVaList([ logLevel.description, message ]) { args in
                CLSLogv("[%@] %@", args)
            }
        }
    }

    func reportMissingLogFile() {
        let message = String(format: "[%@] Could not locate log file.", instanceType(self))
        let wrappedError = LoggingErrorCode.NoLoggingFile.error(withDescription: message)
        logError(message: message, error: wrappedError)
    }
    
}

// MARK: Errors

let LogControllerErrorUserFacingDescriptionKey = String(asRDNSForApp: "dough", domain: "error", subpaths: [ "logging", "user-info", "key", "user-facing-description" ])

enum LoggingErrorCode: Int {

    case NoLoggingFile
    case CouldNotReadLogFile

    func error(withDescription description: String, userInfo: [ AnyHashable: Any ]? = nil) -> NSError {
        let domain = String(asRDNSForApp: "dough", domain: "error", subpaths: [ "logging" ])
        var info: [ AnyHashable: Any ] = [ LogControllerErrorUserFacingDescriptionKey: description ]
        userInfo?.forEach { info[$0.key] = $0.value }
        return NSError(domain: domain, code: self.rawValue, userInfo: info)
    }
}
