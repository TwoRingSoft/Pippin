//
//  SentryAdapter.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/28/26.
//

#if canImport(UIKit)
import Foundation
import Pippin
import Sentry
import SwiftUI
import UIKit

/// Pippin adapter for the Sentry SDK, providing `CrashReporter` and `BugReporter` conformance.
///
/// This file is not built as an SPM target because sentry-cocoa's `Package.swift` distributes
/// pre-built xcframeworks, which can cause runtime symbol mismatches when compiled via SPM.
/// Instead, the host app should:
/// 1. Add the `sentry-cocoa` Xcode project (`Sentry.xcodeproj`) as a child project reference.
/// 2. Compile this file as part of a separate static library target that links the Sentry framework directly.
public final class SentryAdapter: NSObject, EnvironmentallyConscious {
    public var environment: Pippin.Environment?

    public init(serverKey: String, initialKeysAndValues: [String: String]?, configure: ((Options) -> Void)?) {
        Sentry.SentrySDK.start(configureOptions: { options in
            options.dsn = serverKey
#if DEBUG
//            options.debug = true
            options.environment = "development"
#else
            options.debug = false
            options.environment = "production"
#endif
            options.attachScreenshot = true
            options.attachViewHierarchy = true
            options.enableAutoSessionTracking = true
            options.tracesSampleRate = 0.1
            options.enableCaptureFailedRequests = true

            options.configureProfiling = { profilingOptions in
                profilingOptions.sessionSampleRate = 0.1
                profilingOptions.lifecycle = .trace
                profilingOptions.profileAppStarts = true
            }

            if let initialKeysAndValues {
                options.initialScope = { scope in
                    for (key, value) in initialKeysAndValues {
                        scope.setTag(value: value, key: key)
                    }
                    return scope
                }
            }

            configure?(options)
        })
    }

    public convenience init(serverKey: String, initialKeysAndValues: [String: String]?) {
        self.init(serverKey: serverKey, initialKeysAndValues: initialKeysAndValues, configure: nil)
    }

    public init(recipients: [String]) {
        // no-op, it'll already have been initialized as a crash reporter
    }
}

// MARK: CrashReporter
extension SentryAdapter: CrashReporter {

    public var supportsLogs: Bool { true }
    public var supportsBreadcrumbs: Bool { true }

    public func log(message: String) {
        SentrySDK.logger.info(message)
    }

    public func recordBreadcrumb(message: String, category: String, level: LogLevel) {
        let breadcrumb = Breadcrumb(level: level.sentryLevel, category: category)
        breadcrumb.message = message
        SentrySDK.addBreadcrumb(breadcrumb)
    }

    public func recordNonfatalError(error: Error, metadata: [String: Any]?) {
        SentrySDK.capture(error: error) { [weak self] scope in
            if let metadata = metadata {
                for (key, value) in metadata {
                    scope.setExtra(value: value, key: key)
                }
            }
            if let logContents = self?.environment?.logger?.logContents(),
               let logData = logContents.data(using: .utf8) {
                let attachment = Attachment(data: logData, filename: "logs.txt", contentType: "text/plain")
                scope.addAttachment(attachment)
            }
        }
    }

    public func setUser(id: String?, username: String?, email: String?) {
        SentrySDK.configureScope { scope in
            if id == nil && username == nil && email == nil {
                scope.setUser(nil)
                return
            }
            let user = User()
            user.userId = id
            user.username = username
            user.email = email
            scope.setUser(user)
        }
    }

    public func setSessionMetadata(keysAndValues: [String: Any]) {
        SentrySDK.configureScope { scope in
            for (key, value) in keysAndValues {
                scope.setExtra(value: value, key: key)
            }
        }
    }

    public func testCrash() {
        SentrySDK.crash()
    }
}

// MARK: BugReporter
extension SentryAdapter: BugReporter {
    public func show(fromViewController viewController: UIViewController, screenshot: UIImage?, metadata: [String: AnyObject]?) {
        MainActor.assumeIsolated {
            let viewModel = BugReportViewModel { [weak self] message, name, email in
                var attachments: [Attachment]?
                if let logContents = self?.environment?.logger?.logContents(),
                   let logData = logContents.data(using: .utf8) {
                    attachments = [Attachment(data: logData, filename: "logs.txt", contentType: "text/plain")]
                }
                let feedback = SentryFeedback(message: message, name: name, email: email, source: .custom, attachments: attachments)
                SentrySDK.capture(feedback: feedback)
            }
            let hostingController = UIHostingController(rootView: BugReportView(viewModel: viewModel))
            viewController.present(hostingController, animated: true)
        }
    }
}

// MARK: Debuggable
extension SentryAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let foregroundColor = environment?.colors.foreground ?? UIColor.black
        let titleLabel = UILabel.label(withText: "Sentry:", font: environment!.fonts.title, textColor: foregroundColor)

        let crashButton = UIButton(type: .custom)
        crashButton.setTitle("Test crash", for: .normal)
        crashButton.addTarget(self, action: #selector(testCrashAction), for: .touchUpInside)
        crashButton.setTitleColor(foregroundColor, for: .normal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, crashButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }

    @objc private func testCrashAction() {
        testCrash()
    }
}

// MARK: LogLevel → SentryLevel
private extension LogLevel {
    var sentryLevel: SentryLevel {
        switch self {
        case .unknown, .verbose: return .debug
        case .debug: return .debug
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}
#endif
