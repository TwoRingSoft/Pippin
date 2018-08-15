//
//  Environment.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Foundation

/// A protocol that components are tagged with that provides them a way to reach into their environment to use other components, like a logger. Please use responsibly :)
public protocol EnvironmentallyConscious {
    var environment: Environment? { get set }
}

/// A collection of references to objects containing app information and infrastructure.
public class Environment: NSObject {
    
    // MARK: app information
    
    public var appName: String
    public var currentBuild: Build
    public var semanticVersion: SemanticVersion
    
    // MARK: infrastructure
    
    public var coreDataController: CoreDataController!
    public var crashReporter: CrashReporter!
    public var logger: Logger!
    public var alerter: Alerter!
    public var activityIndicator: ActivityIndicator!
    
    // MARK: components
    
    public var bugReporter: BugReporter!
    public var inAppPurchaseVendor: InAppPurchaseVendor!
    
    // MARK: testing/development utilities
    
    public var debugging: Debugging!
    
    // MARK: look/feel
    
    public var fonts: Fonts!
    
    /// Initialize a new app environment. Sets up `appName`, `semanticVersion` and `currentBuild` propertiew from the main bundle.
    override public init() {
        let bundle = Bundle.main
        self.appName = bundle.getAppName()
        self.semanticVersion = bundle.getSemanticVersion()
        self.currentBuild = bundle.getBuild()
    }
    
}
