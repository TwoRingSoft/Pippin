//
//  Environment.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Foundation

/// A collection of references to objects containing app information and infrastructure.
public class Environment: NSObject {
    
    public init(appName: String, currentBuild: Build, semanticVersion: SemanticVersion, coreDataController: CoreDataController, crashReporter: CrashReporter, logger: Logger? = nil, alerter: Alerter? = nil, activityIndicator: ActivityIndicator? = nil, bugReporter: BugReporter? = nil, inAppPurchaseVendor: InAppPurchaseVendor? = nil, debugging: Debugging? = nil) {
        let bundle = Bundle.main
        self.appName = bundle.getAppName()
        self.semanticVersion = bundle.getSemanticVersion()
        self.currentBuild = bundle.getBuild()
        self.coreDataController = coreDataController
        self.crashReporter = crashReporter
        
        let resolvedLogger = logger ?? XCGLoggerAdapter(name: appName, logLevel: .info)
        self.logger = resolvedLogger
        
        self.alerter = alerter ?? SwiftMessagesAdapter()
        self.activityIndicator = activityIndicator ?? JGProgressHUDAdapter()
        self.bugReporter = bugReporter ?? PinpointKitAdapter(logger: resolvedLogger)
        
        self.inAppPurchaseVendor = inAppPurchaseVendor
        self.debugging = debugging
        super.init()
    }

    // MARK: app information
    
    public var appName: String
    public var currentBuild: Build
    public var semanticVersion: SemanticVersion

    // MARK: infrastructure
    
    public var coreDataController: CoreDataController
    public var crashReporter: CrashReporter
    public var logger: Logger
    public var alerter: Alerter
    public var activityIndicator: ActivityIndicator

    // MARK: components
    
    public var bugReporter: BugReporter
    public var inAppPurchaseVendor: InAppPurchaseVendor?
    
    // MARK: testing/development utilities
    
    public var debugging: Debugging?
    
}
