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

public protocol EnvironmentTypes {
    associatedtype DefaultsKey
}

/// A collection of references to objects containing app information and infrastructure.
public class Environment: NSObject {
    // MARK: app information
    public let appName: String
    public let currentBuild: Build
    public let semanticVersion: SemanticVersion
    public let lastLaunchedBuild: Build?
    
    // MARK: infrastructure
    public var coreDataController: CoreDataController!
    public var crashReporter: CrashReporter!
    public var logger: Logger!
    public var alerter: Alerter!
    public var activityIndicator: ActivityIndicator!
    public var defaults: Defaults
    
    // MARK: components
    public var bugReporter: BugReporter!
    public var inAppPurchaseVendor: InAppPurchaseVendor!
    
    // MARK: sensors
    public var locator: Locator?
    
    // MARK: testing/development utilities
    public var debugging: Debugging!
    public var touchVisualizer: TouchVisualization?
    
    // MARK: look/feel
    public var fonts: Fonts
    public var sharedAssetsBundle: Bundle
    
    /// Initialize a new app environment. Sets up `appName`, `semanticVersion` and `currentBuild` propertiew from the main bundle. Wipes out the standard `UserDefaults` if the launch argument for it is activated.
    /// - Parameters:
    ///    - defaults: Optionally provide an object conforming to `Defaults`. It's `environment?` property will be automatically set. If you don't need this, an instance of `DefaultDefaults` is generated for Pippin's internal use.
    ///    - fonts: Optionally provide an object conforming to `Fonts`, otherwise Pippin constructs an instance of `DefaultFonts` for use in UI extensions like `InfoViewController`.
    ///    - sharedAssetsBundle: If you use Pippin UI components that draw images to screen, specify which bundle they'll come from. Defaults to `Bundle.main`.
    public init(defaults: Defaults = DefaultDefaults(), fonts: Fonts = DefaultFonts(), sharedAssetsBundle: Bundle = Bundle.main) {
        let bundle = Bundle.main
        self.appName = bundle.getAppName()
        self.semanticVersion = bundle.getSemanticVersion()
        self.currentBuild = bundle.getBuild()
        self.defaults = defaults
        self.fonts = fonts
        self.sharedAssetsBundle = sharedAssetsBundle
        
        // get previous launch version
        self.lastLaunchedBuild = self.defaults.lastLaunchedBuild
        
        // memoize this launch version
        self.defaults.lastLaunchedVersion = semanticVersion
        self.defaults.lastLaunchedBuild = currentBuild
        
        super.init()
        
        self.defaults.environment = self
        
        if LaunchArgument.wipeDefaults.activated() {
            let defaults = UserDefaults.standard
            defaults.dictionaryRepresentation().keys.forEach {
                defaults.setValue(nil, forKey: $0)
            }
            defaults.synchronize()
        }
    }
    
    /// Check a few standard override locations for the logging level to use with a new `Logger`.
    ///
    /// - Returns: A `LogLevel` found in an override, or `nil` if no override was set.
    public func logLevel() -> LogLevel? {
        // see if we have an xcode scheme launch argument
        if let launchArgumentValue = EnvironmentVariable.logLevel.value(), let logLevel = LogLevel(launchArgumentValue), logLevel != LogLevel.unknown {
            return logLevel
        }
        
        // see if we have a user default saved
        if let defaultsLevel = defaults.logLevel, defaultsLevel != LogLevel.unknown {
            return defaultsLevel
        }
        
        return nil
    }
}
