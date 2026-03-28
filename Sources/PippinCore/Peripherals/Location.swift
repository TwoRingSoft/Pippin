//
//  Location.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/15/18.
//

import CoreLocation
import Foundation

public enum LocatorError: Error {
    case coreLocationError(NSError)
}

public protocol Location {
    var latitude: Double { get }
    var longitude: Double { get }
}

#if canImport(UIKit)
public protocol Locator: EnvironmentallyConscious, Debuggable {
    init(authorizedLocationManager: CLLocationManager?, locatorDelegate: LocatorDelegate)
    func startMonitoringLocation()
    func stopMonitoringLocation()
}
#else
public protocol Locator: EnvironmentallyConscious {
    init(authorizedLocationManager: CLLocationManager?, locatorDelegate: LocatorDelegate)
    func startMonitoringLocation()
    func stopMonitoringLocation()
}
#endif

public protocol LocatorDelegate {
    func locator(locator: Locator, updatedToLocation location: Location)
    func locator(locator: Locator, encounteredError: LocatorError)
}
