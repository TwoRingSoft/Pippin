//
//  DefaultDefaults.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/17/18.
//

import Foundation
import PippinLibrary

public enum DefaultDefaultsKey: String {
    case debugLogging = "debug-logging"
    case lastLaunchedSemanticVersion = "last-launched-semantic-version"
    case lastLaunchedBuildNumber = "last-launched-build-number"
    
    public func keyString() -> String {
        return String(asRDNSForPippinSubpaths: ["user-defaults", "key", self.rawValue])
    }
}

public struct DefaultDefaults: Defaults {
    
    public var environment: Environment?
    
    public init() {}
    
    public var logLevel: LogLevel? {
        get {
            return LogLevel(debugDescription: UserDefaults.standard.string(forKey: DefaultDefaultsKey.debugLogging.keyString()))
        }
        set(newValue) {
            let key = DefaultDefaultsKey.debugLogging.keyString()
            guard let value = newValue else {
                UserDefaults.setAndSynchronize(key: key, value: nil)
                return
            }
            UserDefaults.setAndSynchronize(key: key, value: String(reflecting: value))
        }
    }
    
    public var lastLaunchedBuild: Build? {
        get {
            guard let stringValue = UserDefaults.standard.string(forKey: DefaultDefaultsKey.lastLaunchedBuildNumber.keyString()) else { return nil }
            return Build(stringValue)
        }
        set(newValue) {
            let key = DefaultDefaultsKey.lastLaunchedBuildNumber.keyString()
            guard let value = newValue else {
                UserDefaults.setAndSynchronize(key: key, value: nil)
                return
            }
            UserDefaults.setAndSynchronize(key: key, value: String(describing: value))
        }
    }
    
    public var lastLaunchedVersion: SemanticVersion? {
        get {
            guard let stringValue = UserDefaults.standard.string(forKey: DefaultDefaultsKey.lastLaunchedSemanticVersion.keyString()) else { return nil }
            return SemanticVersion(stringValue)
        }
        set(newValue) {
            let key = DefaultDefaultsKey.lastLaunchedSemanticVersion.keyString()
            guard let value = newValue else {
                UserDefaults.setAndSynchronize(key: key, value: nil)
                return
            }
            UserDefaults.setAndSynchronize(key: key, value: String(describing: value))
        }
    }
    
}
