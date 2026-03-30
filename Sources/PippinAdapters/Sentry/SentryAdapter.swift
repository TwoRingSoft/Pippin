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
import UIKit

public final class SentryAdapter: NSObject, EnvironmentallyConscious {
    public var environment: Environment?

    public init(serverKey: String, initialKeysAndValues: [String: String]?) {
        Sentry.SentrySDK.start(configureOptions: { options in
            options.dsn = serverKey
#if DEBUG
            options.debug = true
#else
            options.debug = false
#endif
            options.attachScreenshot = true
            options.attachViewHierarchy = true

            if let initialKeysAndValues {
                options.initialScope = { scope in
                    for (key, value) in initialKeysAndValues {
                        scope.setTag(value: value, key: key)
                    }
                    return scope
                }
            }
        })
    }

    public init(recipients: [String]) {
        // no-op, it'll already have been initialized as a crash reporter
    }
}

// MARK: CrashReporter
extension SentryAdapter: CrashReporter {
    
    public func log(message: String) {
        let breadcrumb = Breadcrumb(level: .info, category: "log")
        breadcrumb.message = message
        SentrySDK.addBreadcrumb(breadcrumb)
    }

    public func recordNonfatalError(error: Error, metadata: [String: Any]?) {
        SentrySDK.capture(error: error) { scope in
            if let metadata = metadata {
                for (key, value) in metadata {
                    scope.setExtra(value: value, key: key)
                }
            }
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
        let alert = UIAlertController(title: "Report a Bug", message: "Tell us what happened and we'll look into it.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addTextField { $0.placeholder = "Email" }
        alert.addTextField { $0.placeholder = "What went wrong?" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { _ in
            let name = alert.textFields?[0].text
            let email = alert.textFields?[1].text
            let message = alert.textFields?[2].text ?? ""

            let feedback = SentryFeedback(message: message, name: name, email: email, source: .custom)
            SentrySDK.capture(feedback: feedback)
        })

        viewController.present(alert, animated: true)
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
#endif
