//
//  LaunchArguments.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

public enum LaunchArgument: String {

    case uiTest = "ui-test"
    case unlockIAP = "unlock-in-app-purchases"
    case simulateIAPFlow = "simulate-in-app-purchases-flow"
    case simulateProductPurchaseSuccess = "simulate-product-purchase-success"
    case simulateProductPurchaseFailure = "simulate-product-purchase-failure"
    case simulateInAppPurchaseRestoreSuccess = "simulate-in-app-purchase-restore-success"
    case simulateInAppPurchaseRestoreFailure = "simulate-in-app-purchase-restore-failure"

    public func activated() -> Bool {
        return ProcessInfo.processInfo.arguments.contains(String(describing: self))
    }

}

extension LaunchArgument: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "launch-argument", rawValue ])
    }

}
