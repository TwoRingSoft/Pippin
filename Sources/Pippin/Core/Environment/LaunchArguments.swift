//
//  LaunchArguments.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

/// Collection of launch arguments that may be configured in an app launch.
@objc public enum LaunchArgument: Int {

    /// Set up the application for an automated UI test.
    case uiTest

    /// Bypass all checks for IAPs, as if there are none.
    case unlockIAP

    /// Simulate request of available purchase IDs.
    case simulateProductFetch

    /// Any time a purchase is initiated, short circuit to a success callback.
    case simulateProductPurchaseSuccess

    /// Any time a purchase is initiated, short circuit to a failure callback.
    case simulateProductPurchaseFailure

    /// Any time a restore is initiated, short circuit to a success callback.
    case simulateInAppPurchaseRestoreSuccess

    /// Any time a restore is initiated, short circuit to a failure callback.
    case simulateInAppPurchaseRestoreFailure

    /// Wipe any persisted purchases on device on app launch, to test a "clean slate" run
    case wipePersistedInAppPurchases

    /// Determine if the calling launch argument was activated on the app launch.
    ///
    /// - Returns: `true` if the launch argument was configured in the app launch, `false` othewise.
    public func activated() -> Bool {
        return ProcessInfo.processInfo.arguments.contains(String(describing: self))
    }

    private func name() -> String {
        switch self {
        case .uiTest: return "ui-test"
        case .unlockIAP: return "unlock-in-app-purchases"
        case .simulateProductFetch: return "simulate-in-app-purchases-fetch"
        case .simulateProductPurchaseSuccess: return "simulate-product-purchase-success"
        case .simulateProductPurchaseFailure: return "simulate-product-purchase-failure"
        case .simulateInAppPurchaseRestoreSuccess: return "simulate-in-app-purchase-restore-success"
        case .simulateInAppPurchaseRestoreFailure: return "simulate-in-app-purchase-restore-failure"
        case .wipePersistedInAppPurchases: return "wipe-in-app-purchases"
        }
    }

}

extension LaunchArgument: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "launch-argument", name() ])
    }

}

/// A class to expose the functionality of `LaunchArgument` to Objective C. The
/// `activated()` function is a function on an enum and is not able to be
/// exposed to Objective C.
@objc public class LaunchArgumentObjc: NSObject {

    /// Test whether the app was launched with a particular launch argument.
    ///
    /// - Parameter argument: the argument with which we'd like to know whether or not the app was launched
    /// - Returns: `YES` if the app contained the specified launch argument, `NO` otherwise
    @objc public class func applicationLaunched(argument: LaunchArgument) -> Bool {
        return argument.activated()
    }

}
