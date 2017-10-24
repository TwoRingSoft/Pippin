//
//  Logger.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/24/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

enum LoggerError: Swift.Error {
    
    case noLoggingFile(String)
    case couldNotReadLogFile(String, NSError)

}

protocol Logger {

    var logLevel: LogLevel { get set }

    func logDebug(message: String)
    func logInfo(message: String)
    func logWarning(message: String)
    func logVerbose(message: String)
    func logError(message: String, error: Error)

}
