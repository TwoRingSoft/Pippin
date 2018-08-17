//
//  DefaultDefaults.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/17/18.
//

import Foundation

public enum DefaultDefaultKey: String {
    case debugLogging = "debug-logging"
    case lastLaunchedSemanticVersion = "last-launched-semantic-version"
    case lastLaunchedBuildNumber = "last-launched-build-number"
    
    public func keyString() -> String {
        return String(asRDNSForPippinSubpaths: ["user-defaults", "key", self.rawValue])
    }
}

public struct DefaultDefaults: Defaults {
    
    public init() {}
    
    public var logLevel: LogLevel? {
        get {
            return LogLevel(debugDescription: UserDefaults.standard.string(forKey: DefaultDefaultKey.debugLogging.keyString()))
        }
        set(newValue) {
            let key = DefaultDefaultKey.debugLogging.keyString()
            guard let value = newValue else {
                setAndSynchronize(key: key, value: nil)
                return
            }
            setAndSynchronize(key: key, value: String(reflecting: value))
        }
    }
    
    public var lastLaunchedBuild: Build? {
        get {
            guard let stringValue = UserDefaults.standard.string(forKey: DefaultDefaultKey.lastLaunchedBuildNumber.keyString()) else { return nil }
            return Build(stringValue)
        }
        set(newValue) {
            let key = DefaultDefaultKey.lastLaunchedBuildNumber.keyString()
            guard let value = newValue else {
                setAndSynchronize(key: key, value: nil)
                return
            }
            setAndSynchronize(key: key, value: String(describing: value))
        }
    }
    
    public var lastLaunchedVersion: SemanticVersion? {
        get {
            guard let stringValue = UserDefaults.standard.string(forKey: DefaultDefaultKey.lastLaunchedSemanticVersion.keyString()) else { return nil }
            return SemanticVersion(stringValue)
        }
        set(newValue) {
            let key = DefaultDefaultKey.lastLaunchedSemanticVersion.keyString()
            guard let value = newValue else {
                setAndSynchronize(key: key, value: nil)
                return
            }
            setAndSynchronize(key: key, value: String(describing: value))
        }
    }
    
    private func setAndSynchronize(key: String, value: String?) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
}
