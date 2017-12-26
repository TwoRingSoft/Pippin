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

    public func activated() -> Bool {
        return ProcessInfo.processInfo.arguments.contains(String(describing: self))
    }

}

extension LaunchArgument: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "launch-argument", rawValue ])
    }

}
