//
//  OSLogAdapter.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/29/26.
//

#if canImport(UIKit)
import Foundation
import os.log
import OSLog
import Pippin
import UIKit

public final class OSLogAdapter: NSObject, EnvironmentallyConscious {
    public var environment: Environment?
    public var logLevel: LogLevel = .info

    private let logger: os.Logger
    private let subsystem: String
    private let category: String

    public init(subsystem: String, category: String = "general", logLevel: LogLevel = .info) {
        self.subsystem = subsystem
        self.category = category
        self.logLevel = logLevel
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
}

// MARK: Logger
extension OSLogAdapter: Pippin.Logger {

    public func logVerbose(message: String) {
        guard logLevel.rawValue <= LogLevel.verbose.rawValue else { return }
        logger.trace("\(message, privacy: .public)")
        forwardToCrashReporter(message: message, level: .verbose)
    }

    public func logDebug(message: String) {
        guard logLevel.rawValue <= LogLevel.debug.rawValue else { return }
        logger.debug("\(message, privacy: .public)")
        forwardToCrashReporter(message: message, level: .debug)
    }

    public func logInfo(message: String) {
        guard logLevel.rawValue <= LogLevel.info.rawValue else { return }
        logger.info("\(message, privacy: .public)")
        forwardToCrashReporter(message: message, level: .info)
    }

    public func logWarning(message: String) {
        guard logLevel.rawValue <= LogLevel.warning.rawValue else { return }
        logger.warning("\(message, privacy: .public)")
        forwardToCrashReporter(message: message, level: .warning)
    }

    public func logError(message: String, error: Error) {
        let fullMessage = "\(message): \(error.localizedDescription)"
        logger.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        forwardToCrashReporter(message: fullMessage, level: .error)
        environment?.crashReporter?.recordNonfatalError(error: error, metadata: nil)
    }

    public func logContents() -> String? {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(timeIntervalSinceLatestBoot: 0)
            let predicate = NSPredicate(format: "subsystem == %@", subsystem)
            let entries = try store.getEntries(at: position, matching: predicate)
            let lines = entries.compactMap { entry -> String? in
                guard let logEntry = entry as? OSLogEntryLog else { return nil }
                let timestamp = ISO8601DateFormatter().string(from: logEntry.date)
                return "[\(timestamp)] [\(logEntry.level.description)] \(logEntry.composedMessage)"
            }
            return lines.joined(separator: "\n")
        } catch {
            logger.error("Failed to read log store: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    public func resetLogs() {
        // OSLog doesn't support clearing logs programmatically
    }
}

// MARK: Private
private extension OSLogAdapter {
    func forwardToCrashReporter(message: String, level: LogLevel) {
        guard let crashReporter = environment?.crashReporter else { return }
        if crashReporter.supportsLogs {
            crashReporter.log(message: "[\(level)] \(message)")
        } else if crashReporter.supportsBreadcrumbs {
            crashReporter.recordBreadcrumb(message: message, category: category, level: level)
        }
    }
}

// MARK: Debuggable
extension OSLogAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let foregroundColor = environment?.colors.foreground ?? .black
        let titleLabel = UILabel.label(withText: "Logger:", font: environment!.fonts.title, textColor: foregroundColor)

        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }
}

// MARK: OSLogEntryLog.Level description
private extension OSLogEntryLog.Level {
    var description: String {
        switch self {
        case .undefined: return "undefined"
        case .debug: return "debug"
        case .info: return "info"
        case .notice: return "notice"
        case .error: return "error"
        case .fault: return "fault"
        @unknown default: return "unknown"
        }
    }
}
#endif
