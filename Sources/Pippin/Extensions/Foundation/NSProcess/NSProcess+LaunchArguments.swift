//
//  ProcessInfo+LaunchArguments.swift
//  Pippin
//
//  Created by Andrew McKnight on 09/15/18.
//

import Foundation

public extension ProcessInfo {
    /// Determine if the provided launch argument was activated on the app launch.
    ///
    /// - Parameter launchArgument: The `CustomStringConvertible` instance encapsulating the launch argument to test, as it was provided to the app launcher.
    ///
    /// - Returns: `true` if the launch argument was configured in the app launch, `false` othewise.
    class func launchedWith(launchArgument: CustomStringConvertible) -> Bool {
        return processInfo.arguments.contains(String(describing: launchArgument))
    }
}
