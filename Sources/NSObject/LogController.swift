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

final class LogController: NSObject {

    fileprivate var appName: String!
    fileprivate var loggingQueue: DispatchQueue!
    fileprivate var logFileURL: URL?
    fileprivate let xcgLogger = XCGLogger(identifier: XCGLogger.Constants.fileDestinationIdentifier, includeDefaultDestinations: true)

    init(forAppNamed appName: String, logLevel: XCGLogger.Level) {
        super.init()
        self.appName = appName
        self.loggingQueue = DispatchQueue(label: "com.tworingsoft.\(appName).logger-queue")

        guard let logFileURL = urlForFilename(fileName: "\(appName).log", inDirectoryType: .libraryDirectory) else {
            reportMissingLogFile()
            return
        }
        self.logFileURL = logFileURL

        xcgLogger.setup(level: logLevel,
                        showLogIdentifier: false,
                        showFunctionName: false,
                        showThreadName: false,
                        showLevel: true,
                        showFileNames: false,
                        showLineNumbers: false,
                        showDate: true,
                        writeToFile: logFileURL,
                        fileLevel: logLevel
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
            let domain: ErrorDomain = .Logging
            let code: LoggingErrorCode = .CouldNotReadLogFile
            let wrappedError = NSError(domain: domain.domainString(),
                                       code: code.rawValue,
                                       userInfo: [ NSLocalizedDescriptionKey: message, NSUnderlyingErrorKey: error as NSError])
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
        let domain: ErrorDomain = .Logging
        let code: LoggingErrorCode = .NoLoggingFile
        let error = NSError(domain: domain.domainString(),
                            code: code.rawValue,
                            userInfo: [ NSLocalizedDescriptionKey: message ])
        logError(message: message, error: error)
    }
    
}
