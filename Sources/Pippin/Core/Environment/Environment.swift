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
    
    public var appName: String?
    public var currentBuild: Build?
    public var semanticVersion: SemanticVersion?

    // MARK: infrastructure
    
    public var crashReporter: CrashReporter?
    public var coreDataController: CoreDataController?
    public var logger: Logger?
    public var alerter: Alerter?
    public var activityIndicator: ActivityIndicator?

    // MARK: components
    
    public var bugReporter: BugReporter?
    public var inAppPurchaseVendor: InAppPurchaseVendor?
    
    // MARK: testing/development utilities
    
    public var debugging: Debugging?
    
}
