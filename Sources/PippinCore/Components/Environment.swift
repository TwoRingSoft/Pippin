//
//  Environment.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Foundation
import PippinLibrary

private class PippinDummyRDNSBundleSearchClass {}

extension String {
    init(asRDNSForPippinSubpaths subpaths: [String]) {
        precondition(subpaths.count > 0)
        precondition(subpaths.filter({ $0.count > 0 }).count > 0)
        self = String(asRDNSWithSubpaths: [Bundle(for: PippinDummyRDNSBundleSearchClass.self).identifier] + subpaths)
    }
}

/// A protocol that components are tagged with that provides them a way to reach into their environment to use other components, like a logger. Please use responsibly :)
public protocol EnvironmentallyConscious {
    var environment: Environment? { get set }
}

public extension Environment {
    /// Errors that may be used by apps to describe adverse situations related to the environment.
    enum Error: NSErrorConvertible {
        /// Expected an initialized `CoreDataController` but none was present.
        case missingCoreDataController

        /// Expected an initialized `InAppPurchaseVendor` but none was present.
        case missingInAppPurchaseVendor

        public var code: Int {
            switch self {
            case .missingCoreDataController: return 0
            case .missingInAppPurchaseVendor: return 1
            }
        }

        public var nsError: NSError {
            return NSError(domain: String(asRDNSForPippinSubpaths: ["environment", "error"]), code: code, userInfo: [:])
        }
    }
}

/// A collection of references to objects containing app information and infrastructure.
public class Environment: NSObject {
    // MARK: app information
    public let appName: String
    public let currentBuild: Build
    public let semanticVersion: SemanticVersion
    public let lastLaunchedBuild: Build?
    
    // MARK: infrastructure
    public var model: Model?
    public var crashReporter: CrashReporter?
    public var logger: Logger?
    public var alerter: Alerter?
    public var activityIndicator: ActivityIndicator?
    public var defaults: Defaults
    
    // MARK: components
    public var bugReporter: BugReporter?
    public var inAppPurchaseVendor: InAppPurchaseVendor?
    
    // MARK: sensors
    public var locator: Locator?
    
    // MARK: testing/development utilities
    #if DEBUG
    public var debugging: DebugMenuPresenter?
    #endif
    public var touchVisualizer: TouchVisualization?
    
    // MARK: look/feel
    public var fonts: Fonts
    public var colors: Colors
    public var sharedAssetsBundle: Bundle
    
    /// Initialize a new app environment. Sets up `appName`, `semanticVersion` and `currentBuild` propertiew from the main bundle. Wipes out the standard `UserDefaults` if the launch argument for it is activated.
    /// - Parameters:
    ///    - defaults: Optionally provide an object conforming to `Defaults`. It's `environment?` property will be automatically set. If you don't need this, an instance of `DefaultDefaults` is generated for Pippin's internal use.
    ///    - fonts: Optionally provide an object conforming to `Fonts`, otherwise Pippin constructs an instance of `DefaultFonts` for use in UI extensions like `InfoViewController`.
    ///    - sharedAssetsBundle: If you use Pippin UI components that draw images to screen, specify which bundle they'll come from. Defaults to `Bundle.main`.
    ///    - colors: Optionally provide an object conforming to `Colors`, otherwise Pippin constructs an instande of `DefaultColors` for use in UI extensions like `InfoViewController`.
    public init(
        defaults: Defaults = DefaultDefaults(),
        fonts: Fonts = DefaultFonts(),
        sharedAssetsBundle: Bundle = Bundle.main,
        colors: Colors = DefaultColors()
    ) {
        let bundle = Bundle.main
        self.appName = bundle.getAppName()
        self.semanticVersion = bundle.getSemanticVersion()
        self.currentBuild = bundle.getBuild()
        self.defaults = defaults
        self.fonts = fonts
        self.sharedAssetsBundle = sharedAssetsBundle
        self.colors = colors
        
        // get previous launch version
        self.lastLaunchedBuild = self.defaults.lastLaunchedBuild
        
        // memoize this launch version
        self.defaults.lastLaunchedVersion = semanticVersion
        self.defaults.lastLaunchedBuild = currentBuild
        
        super.init()
        
        self.defaults.environment = self
        
        if ProcessInfo.launchedWith(launchArgument: LaunchArgument.wipeDefaults) {
            let defaults = UserDefaults.standard
            defaults.dictionaryRepresentation().keys.forEach {
                defaults.setValue(nil, forKey: $0)
            }
            defaults.synchronize()
        }
    }
    
    /// Check a few standard override locations for the logging level to use with a new `Logger`.
    /// - Returns: A `LogLevel` found in an override, or `debug` for debugging builds or `info` for non-debug builds..
    public func logLevel() -> LogLevel {
        // log verbosely for ui tests
        if ProcessInfo.launchedWith(launchArgument: LaunchArgument.uiTest) {
            return .verbose
        }

        // see if we have an xcode scheme launch argument
        if let launchArgumentValue = EnvironmentVariable.logLevel.value(), let logLevel = LogLevel(launchArgumentValue), logLevel != LogLevel.unknown {
            return logLevel
        }

        // see if we have a user default saved
        if let defaultsLevel = defaults.logLevel, defaultsLevel != LogLevel.unknown {
            return defaultsLevel
        }

        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }

    /// Goes through each property that conforms to `EnvironmentallyConscious` and assigns the back reference to the `Environment` to which it belongs.
    public func connectEnvironment() {
        logger?.environment = self
        alerter?.environment = self
        model?.environment = self
        crashReporter?.environment = self
        activityIndicator?.environment = self
        bugReporter?.environment = self
        inAppPurchaseVendor?.environment = self
        locator?.environment = self
        #if DEBUG
        debugging?.environment = self
        #endif
        touchVisualizer?.environment = self
        defaults.environment = self
    }
}
