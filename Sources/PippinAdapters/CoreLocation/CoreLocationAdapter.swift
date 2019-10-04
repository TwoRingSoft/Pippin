//
//  CoreLocationAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/15/18.
//

import CoreLocation
import Foundation
import Pippin
import Result

extension CLLocation: Location {
    public var latitude: Double {
        return self.coordinate.latitude
    }

    public var longitude: Double {
        return self.coordinate.longitude
    }
}

public class CoreLocationAdapter: NSObject, Locator {
    public var environment: Environment?
    private var authorizedLocationManager: CLLocationManager?
    private var locatorDelegate: LocatorDelegate
    private var authToken: AuthorizedCLLocationManager?
    
    /// Initialize a new `CoreLocationAdapter` instance with a delegate and optionally preauthorized `CLLocationManager`. If one is not provided, then one will be authorized when necessary.
    ///
    /// - Parameters:
    ///   - authorizedLocationManager: A preauthorized `CLLocationManager`. If one is not provided, then one will be authorized when necessary.
    ///   - locatorDelegate: A delegate to respond to callbacks.
    public required init(authorizedLocationManager: CLLocationManager? = nil, locatorDelegate: LocatorDelegate) {
        self.authorizedLocationManager = authorizedLocationManager
        self.locatorDelegate = locatorDelegate
        super.init()
        authorizedLocationManager?.delegate = self
    }
    
    // MARK: Debuggable
    public func debuggingControlPanel() -> UIView {
        return UILabel.label(withText: "No current CoreLocationAdapter debugging controls")
    }
    
    public func startMonitoringLocation() {
        if let authorizedLocationManager = authorizedLocationManager {
            authorizedLocationManager.startUpdatingLocation()
        } else {
            authToken = AuthorizedCLLocationManager.authorizedLocationManager(scope: .whenInUse) { (authorizationResult) in
                switch authorizationResult {
                case .success(let authorizedLocationManager):
                    self.authorizedLocationManager = authorizedLocationManager
                    authorizedLocationManager.delegate = self
                    authorizedLocationManager.startUpdatingLocation()
                case .failure(let error):
                    self.locatorDelegate.locator(locator: self, encounteredError: LocatorError.coreLocationError(error))
                }
                self.authToken = nil
            }
        }
    }
    
    public func stopMonitoringLocation() {
        authorizedLocationManager?.stopUpdatingLocation()
    }
}

extension CoreLocationAdapter: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locatorDelegate.locator(locator: self, updatedToLocation: location)
        }
    }
}
