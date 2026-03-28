//
//  DefaultEnvironment.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 9/21/19.
//

import Foundation
import Pippin
#if canImport(UIKit)
import UIKit

public extension Environment {
    /// Construct a new `Environment` with some default adapters.
    ///
    /// Currently provides default instances of these adapters:
    ///  - `ActivityIndicator`: `JGProgressHUDAdapter`
    ///  - `Alerter`: `SwiftMessagesAdapter`
    ///  - `Logger`: `XCGLoggerAdapter`
    /// Any component may still be switched out afterwards as desired.
    @MainActor static func `default`() -> Environment {
        let environment = Environment()

        environment.activityIndicator = JGProgressHUDAdapter()
        environment.logger = XCGLoggerAdapter(name: "\(environment.appName).log", logLevel: environment.logLevel())
        environment.alerter = SwiftMessagesAdapter()


        environment.connectEnvironment()

        return environment
    }
}
#endif
