//
//  AuthorizedCLLocationManager.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/17/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import CoreLocation
import Foundation

private let firstLaunchTokenUserDefaultKey = "com.tworingsoft.can-i-haz.authorized-location-manager.user-defaults.key.first-launch-token"

enum AuthorizationScope {
    case WhenInUse
    case Always
}

typealias AuthorizedLocationManagerResult = (locationManager: CLLocationManager?, error: NSError?)

enum AuthorizationErrorCode: Int {
    case Denied
    case Disabled
}

private let AuthorizationErrorDomain = "com.tworingsoft.can-i-haz.authorized-location-manager.error"
private let AuthorizationErrorDescription = "Location services not available."

final class AuthorizedCLLocationManager: NSObject {

    private static let singleton = AuthorizedCLLocationManager()

    private var authorizationCompletion: (Bool -> Void)!
    private var authorizationScope: AuthorizationScope!

    class func authorizedLocationManager(scope: AuthorizationScope, completion: AuthorizedLocationManagerResult -> Void) {

        if !CLLocationManager.locationServicesEnabled() {
            completion((locationManager: nil, error: NSError(domain: AuthorizationErrorDomain, code: AuthorizationErrorCode.Disabled.rawValue, userInfo: [NSLocalizedDescriptionKey: AuthorizationErrorDescription, NSLocalizedFailureReasonErrorKey: "The user has disabled location services for their device."])))
            return
        }

        self.checkRequiredPlistValues(scope)
        
        singleton.createAndAuthorizeNewLocationManager(scope, completion: completion)
    }

    private class func checkRequiredPlistValues(scope: AuthorizationScope) {

        var requiredPlistKey: String!
        switch scope {
        case .Always:
            requiredPlistKey = "NSLocationAlwaysUsageDescription"
            break
        case .WhenInUse:
            requiredPlistKey = "NSLocationWhenInUseUsageDescription"
            break
        }

        guard let infoDictionary = NSBundle.mainBundle().infoDictionary else {
            fatalError("Could not locate Info.plist keys and values.")
        }
        guard let requiredLocationRequestDescriptionValue = infoDictionary[requiredPlistKey] as? String else {
            fatalError("You must provide a value for \(requiredPlistKey) in your app's Info.plist for the location services request dialog to be shown to the user.")
        }
        if requiredLocationRequestDescriptionValue.characters.count == 0 {
            fatalError("You provided a description value for \(requiredPlistKey) with length 0. This string is displayed to the user in the request prompt; consider providing more information why you are requesting location services.")
        }
    }

    private func createAndAuthorizeNewLocationManager(scope: AuthorizationScope, completion: (AuthorizedLocationManagerResult -> Void)) {

        authorizationScope = scope

        var locationManager: CLLocationManager?
        self.authorizationCompletion = { authorized in

            if authorized {
                locationManager?.delegate = nil
                completion((locationManager: locationManager, error: nil))
            } else {
                completion((locationManager: nil, error: NSError(domain: AuthorizationErrorDomain, code: AuthorizationErrorCode.Denied.rawValue, userInfo: [NSLocalizedDescriptionKey: AuthorizationErrorDescription, NSLocalizedFailureReasonErrorKey: "The user has denied location services for this app."])))
            }
        }

        locationManager = CLLocationManager()
        locationManager!.delegate = self
    }

}

extension AuthorizedCLLocationManager: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        var authorized = false

        switch status {
        case .AuthorizedAlways:
            authorized = true
            break
        case .AuthorizedWhenInUse:
            authorized = true
            break
        case .Denied:
            authorized = false
            break
        case .NotDetermined:
            authorized = false
            break
        case .Restricted:
            authorized = false
            break
        }

        if authorized {
            authorizationCompletion(true)
            return
        }

        let defaults = NSUserDefaults.standardUserDefaults()
        let appHasLaunchedAtLeastOnceBefore = defaults.boolForKey(firstLaunchTokenUserDefaultKey)

        if !appHasLaunchedAtLeastOnceBefore {
            defaults.setBool(true, forKey: firstLaunchTokenUserDefaultKey)
            defaults.synchronize()

            let scope: AuthorizationScope = self.authorizationScope
            switch scope {
            case .WhenInUse:
                manager.requestWhenInUseAuthorization()
                break
            case .Always:
                manager.requestAlwaysAuthorization()
                break
            }
            
            return
        }
        
        authorizationCompletion(false)
    }
    
}
