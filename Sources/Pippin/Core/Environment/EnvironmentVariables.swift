//
//  EnvironmentVariables.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

/// An enumeration of possible keys that can be passed into a build of an app, either by using the Xcode Scheme > Run > Arguments > Environment Variables area, or on the command line when running `xcodebuild`.
public enum EnvironmentVariable: String {

    /// The string separator for simulated restored in app purchases, used in the value for `simulatedRestoredInAppPurchaseIdentifiers`.
    public static let simulatedInAppPurchaseIdentifierSeparator = ":"
    
    /// The string separator for simulated locations.
    public static let simulatedLocationListDelimiter = ";"
    public static let simulatedLocationTimeDelimiter = ":"
    public static let simulatedLocationCoordinateDelimiter = ","

    /// A log leve to use as an override to the default.
    case logLevel = "log-level"

    /// A set of product IDs to use when simulating the restoration of in app purchases, to return as the set being restored.
    case simulatedRestoredInAppPurchaseIdentifiers = "simulated-restored-in-app-purchase-identifiers"

    /// A set of product IDs to use when simulating checking the local disk for persisted purchases.
    case simulatedPurchasedInAppPurchaseIdentifiers = "simulated-purchased-in-app-purchase-identifiers"
    
    /// A set of locations with time offsets, in the format
    ///     <time-offset>:<latitude>,<longitude>
    /// supplied in a list delimited by the value in `simulatedLocationListDelimiter`.
    case simulatedLocations = "simulated-locations"

    /// Get the value passed in for the calling environment variable.
    ///
    /// - Returns: The string contents assigned to the calling environment variable, if one was provided.
    public func value() -> String? {
        return ProcessInfo.processInfo.environment[String(describing: self)] as String?
    }

}

extension EnvironmentVariable: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "environment-variable", rawValue ])
    }

}
