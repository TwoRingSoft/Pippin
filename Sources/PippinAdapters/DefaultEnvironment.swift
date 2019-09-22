//
//  DefaultEnvironment.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 9/21/19.
//

import Foundation
import Pippin

public extension Environment {
    /// Construct a new `Environment` with some default adapters.
    ///
    /// Currently provides default instances of these adapters:
    ///  - `ActivityIndicator`: `JGProgressHUDAdapter`
    ///  - `Alerter`: `SwiftMessagesAdapter`
    ///  - `Logger`: `XCGLoggerAdapter`
    /// Any component may still be switched out afterwards as desired.
    ///
    /// TODO: add a `CountlyAdapter` default for `CrashReporter`.
    ///
    /// - Parameters:
    ///     - bugReportRecipients: The email addresses to which bug reports should be sent. Optional; if provided, an instance of `PinpointKitAdapter` (`BugReporter`) is constructed.
    ///     - touchVizRootVC: The root `UIViewController` that will be used to construct the app hierarchy to enable touch visualization. Optional; if provided, an instance of `COSTouchVisualizerAdapter` (`TouchVisualization`) is constructed.
    ///
    /// - Note: `CrashlyticsAdapter` may not be included due to it's static dependency and limitations of CocoaPods.
    static func `default`(bugReportRecipients: [String]? = nil, touchVizRootVC: UIViewController? = nil) -> Environment {
        let environment = Environment()

        environment.activityIndicator = JGProgressHUDAdapter()
        environment.logger = XCGLoggerAdapter(name: "\(environment.appName).log", logLevel: environment.logLevel())
        environment.alerter = SwiftMessagesAdapter()

        if let touchVizRootVC = touchVizRootVC {
            environment.touchVisualizer = COSTouchVisualizerAdapter(rootViewController: touchVizRootVC)
        }

        if let bugReportRecipients = bugReportRecipients {
            environment.bugReporter = PinpointKitAdapter(recipients: bugReportRecipients)
        }

        environment.connectEnvironment()

        return environment
    }
}
