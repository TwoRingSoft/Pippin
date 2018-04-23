//
//  LaunchArguments.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

/// Collection of launch arguments that may be configured in an app launch.
public enum LaunchArgument: String {

    /// Set up the application for an automated UI test.
    case uiTest = "ui-test"

    /// Bypass all checks for IAPs, as if there are none.
    case unlockIAP = "unlock-in-app-purchases"

    /// Simulate request of available purchase IDs.
    case simulateIAPFlow = "simulate-in-app-purchases-flow"

    /// Any time a purchase is initiated, short circuit to a success callback.
    case simulateProductPurchaseSuccess = "simulate-product-purchase-success"

    /// Any time a purchase is initiated, short circuit to a failure callback.
    case simulateProductPurchaseFailure = "simulate-product-purchase-failure"

    /// Any time a restore is initiated, short circuit to a success callback.
    case simulateInAppPurchaseRestoreSuccess = "simulate-in-app-purchase-restore-success"

    /// Any time a restore is initiated, short circuit to a failure callback.
    case simulateInAppPurchaseRestoreFailure = "simulate-in-app-purchase-restore-failure"

    /// Wipe any persisted purchases on device on app launch, to test a "clean slate" run
    case wipePersistedInAppPurchases = "wipe-in-app-purchases"


    /// Determine if the calling launch argument was activated on the app launch.
    ///
    /// - Returns: `true` if the launch argument was configured in the app launch, `false` othewise.
    public func activated() -> Bool {
        return ProcessInfo.processInfo.arguments.contains(String(describing: self))
    }

}

extension LaunchArgument: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "launch-argument", rawValue ])
    }

}
