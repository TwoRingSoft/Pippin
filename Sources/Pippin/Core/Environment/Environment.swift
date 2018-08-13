//
//  Environment.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Foundation

/// A collection of references to objects containing app information and infrastructure.
public class Environment: NSObject {
    
    // MARK: app information
    
    public var appName: String
    public var currentBuild: Build
    public var semanticVersion: SemanticVersion
    
    // MARK: infrastructure
    
    public var coreDataController: CoreDataController?
    public var crashReporter: CrashReporter?
    public var logger: Logger
    public var alerter: Alerter
    public var activityIndicator: ActivityIndicator
    
    // MARK: components
    
    public var bugReporter: BugReporter
    public var inAppPurchaseVendor: InAppPurchaseVendor?
    
    // MARK: testing/development utilities
    
    public var debugging: Debugging?
    
    /// Initialize a new app environment.
    ///
    /// - Parameters:
    ///   - coreDataController: Instance of CoreDataController managing the data model. Optional.
    ///   - crashReporter: Instance conforming to `CrashReporter` protocol. Optional
    ///   - logger: Instance conforming to `Logger` protocol, or if one is not provided, a new instance of `XCGLoggerAdapter` using the app's main bundle name for a log name, at `info` logging level.
    ///   - alerter: Instance conforming to `Alerter` protocol, or if one is not provided, a new instance of `SwiftMessagesAdapter`.
    ///   - activityIndicator: Instance conforming to `ActivityIndicator` protocol, or if one is not provided, a new instance of `JGProgressHUDAdapter`.
    ///   - bugReporter: Instance conforming to `BugReporter` protocol, or if one is not provided, a new instance of `PinpointKitAdapter`.
    ///   - inAppPurchaseVendor: Instance conforming to `InAppPurchaseVendor` protocol. Optional.
    ///   - debugging: Instance conforming to `Debugging` protocol. Optional.
    public init(
        coreDataController: CoreDataController? = nil,
        crashReporter: CrashReporter? = nil,
        logger: Logger = XCGLoggerAdapter(name: Bundle.main.getAppName(), logLevel: .info),
        alerter: Alerter = SwiftMessagesAdapter(),
        activityIndicator: ActivityIndicator = JGProgressHUDAdapter(),
        bugReporter: BugReporter = PinpointKitAdapter(),
        inAppPurchaseVendor: InAppPurchaseVendor? = nil,
        debugging: Debugging? = nil
    ) {
        let bundle = Bundle.main
        self.appName = bundle.getAppName()
        self.semanticVersion = bundle.getSemanticVersion()
        self.currentBuild = bundle.getBuild()

        self.coreDataController = coreDataController
        self.crashReporter = crashReporter
        self.logger = logger
        self.alerter = alerter
        self.activityIndicator = activityIndicator
        
        self.bugReporter = bugReporter
        self.inAppPurchaseVendor = inAppPurchaseVendor
        
        self.debugging = debugging
        
        super.init()
        
        self.crashReporter?.logger = logger
        self.coreDataController?.logger = logger
        self.alerter.logger = logger
        self.activityIndicator.logger = logger
        self.bugReporter.logger = logger
        self.debugging?.logger = logger
        self.inAppPurchaseVendor?.logger = logger
    }
    
}
