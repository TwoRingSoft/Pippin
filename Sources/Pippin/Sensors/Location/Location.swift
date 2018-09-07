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

public protocol Locator: Debuggable, EnvironmentallyConscious {
    init(authorizedLocationManager: CLLocationManager?, locatorDelegate: LocatorDelegate)
    func startMonitoringLocation()
    func stopMonitoringLocation()
}

public protocol LocatorDelegate {
    func locator(locator: Locator, updatedToLocation location: CLLocation)
    func locator(locator: Locator, encounteredError: LocatorError)
}
