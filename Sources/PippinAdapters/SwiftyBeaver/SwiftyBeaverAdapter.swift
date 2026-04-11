import Foundation
import Pippin
import SwiftyBeaver

public final class SwiftyBeaverAdapter: NSObject {
    public var environment: Environment?

    private var _logLevel: LogLevel
    private let beaver = SwiftyBeaver.self
    public let logFileURL: URL

    public init(name: String, logLevel: LogLevel) {
        self._logLevel = logLevel

        let logsDir = FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs", isDirectory: true)
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        logFileURL = logsDir.appendingPathComponent("\(name).log")

        super.init()

        let format = "$DHH:mm:ss.SSS$d $C$L$c $M"

        let file = FileDestination(logFileURL: logFileURL)
        file.minLevel = logLevel.swiftyBeaverLevel
        file.format = format
        beaver.addDestination(file)

        #if DEBUG
        let console = ConsoleDestination()
        console.minLevel = logLevel.swiftyBeaverLevel
        console.format = format
        beaver.addDestination(console)
        #endif
    }

    /// All log file URLs written under Library/Logs/ by any SwiftyBeaverAdapter instance.
    public static func allLogFileURLs() -> [URL] {
        let logsDir = FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs", isDirectory: true)
        return (try? FileManager.default.contentsOfDirectory(
            at: logsDir,
            includingPropertiesForKeys: nil
        ))?.filter { $0.pathExtension == "log" } ?? []
    }
}

// MARK: - Logger

extension SwiftyBeaverAdapter: Pippin.Logger {
    public var logLevel: LogLevel {
        get { _logLevel }
        set { _logLevel = newValue }
    }

    public func logVerbose(message: String) {
        beaver.verbose(message)
        forward(message: message, level: .verbose)
    }

    public func logDebug(message: String) {
        beaver.debug(message)
        forward(message: message, level: .debug)
    }

    public func logInfo(message: String) {
        beaver.info(message)
        forward(message: message, level: .info)
    }

    public func logWarning(message: String) {
        beaver.warning(message)
        forward(message: message, level: .warning)
    }

    public func logError(message: String, error: Error) {
        beaver.error("\(message): \(error.localizedDescription)")
        forward(message: message, level: .error)
        environment?.crashReporter?.recordNonfatalError(error: error, metadata: nil)
    }

    public func logContents() -> String? {
        try? String(contentsOf: logFileURL, encoding: .utf8)
    }

    public func resetLogs() {
        try? FileManager.default.removeItem(at: logFileURL)
    }
}

// MARK: - Debuggable

#if canImport(UIKit)
import UIKit

extension SwiftyBeaverAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        UIView()
    }
}
#endif

// MARK: - Private

private extension SwiftyBeaverAdapter {
    func forward(message: String, level: LogLevel) {
        guard let crashReporter = environment?.crashReporter else { return }
        if crashReporter.supportsLogs {
            crashReporter.log(message: "[\(level)] \(message)")
        } else if crashReporter.supportsBreadcrumbs {
            crashReporter.recordBreadcrumb(message: message, category: "swiftybeaver", level: level)
        }
    }
}

// MARK: - LogLevel mapping

private extension LogLevel {
    var swiftyBeaverLevel: SwiftyBeaver.Level {
        switch self {
        case .unknown: return .info
        case .verbose: return .verbose
        case .debug: return .debug
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}
