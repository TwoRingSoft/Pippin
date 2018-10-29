//
//  Defaults.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/17/18.
//

import Foundation

/// A protocol providing a type for a collection of keys used in the defaults' backing store, and a way to convert them to their canonical `String` forms.
///
/// - Note: There is a default implementation, `DefaultDefaultsKey`, that Pippin uses in case you don't provide your own `Defaults` when initializing a new `Environment`. Check its implementation for reference when creating your own, both for its usage of an `enum` and its usage of `String(asRDNSForCurrentAppWithSubpaths:)` to create a likely-unique key for the backing store.
public protocol DefaultsKey {
    /// - Returns: A canonical `String` representation of your key for usage in the defaults backing store.
    ///
    func keyString() -> String
}

/// A protocol defining a type to pass around an access object to work with the underlying defaults mechanism. Provided are some standard defaults Pippin uses, and you can add your own as well.
///
/// - Note: There is a default implementation, `DefaultDefaults`, that Pippin uses in case you don't provide your own when initializing `Environment`; just copy that implementation to get started with your own.
public protocol Defaults: EnvironmentallyConscious {
    var logLevel: LogLevel? { get set }
    var lastLaunchedBuild: Build? { get set }
    var lastLaunchedVersion: SemanticVersion? { get set }
}
