//
//  AuthorizedCLLocationManager.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/17/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import CoreLocation
import Foundation
import Result

public typealias AuthorizedLocationManagerResult = Result<CLLocationManager, NSError>

enum AuthorizationErrorCode: Int {
    case denied
    case disabled
    case restricted
}

private let AuthorizationErrorDomain = "com.tworingsoft.can-i-haz.authorized-location-manager.error"
private let AuthorizationErrorDescription = "Location services not available."

public class AuthorizedCLLocationManager: NSObject {
    public enum AuthorizationScope: Int {
        case whenInUse
        case always
    }

    public typealias AuthorizationCompletion = (AuthorizedLocationManagerResult) -> Void
    private var authorizationCompletion: AuthorizationCompletion
    private var authorizationScope: AuthorizationScope
    
    private var locationManager: CLLocationManager?

    private init(authorizationScope: AuthorizationScope, authorizationCompletion: @escaping AuthorizationCompletion) {
        self.authorizationScope = authorizationScope
        self.authorizationCompletion = authorizationCompletion
        super.init()
    }

    /// Put user into a UI flow to gain authorization for using location services, or detect permission previously set by user.
    /// - Parameter scope: The `AuthorizationScope` to request from the user.
    /// - Parameter completion: Handler providing either an authorized `CLLocationManager` or an error explaining why one couldn't be provided.
    /// - Returns: a token instance of `AuthorizedCLLocationManager`. Keep a reference to this for the duration of the authorization flow.
    /// - Warning: you are responsible for guarding against any device configurations that affect `CLLocation` availability, such as running on a simulator.
    public class func authorizedLocationManager(scope: AuthorizationScope, completion: @escaping AuthorizationCompletion) -> AuthorizedCLLocationManager? {
        guard CLLocationManager.locationServicesEnabled() else {
            let error = NSError(domain: AuthorizationErrorDomain, code: AuthorizationErrorCode.disabled.rawValue, userInfo: [NSLocalizedDescriptionKey: AuthorizationErrorDescription, NSLocalizedFailureReasonErrorKey: "The user has disabled location services for their device."])
            completion(.failure(error))
            return nil
        }

        let token = AuthorizedCLLocationManager(authorizationScope: scope, authorizationCompletion: completion)
        token.createAndAuthorizeNewLocationManager(scope, completion: completion)
        return token
    }

}

extension AuthorizedCLLocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        func requestPermission() {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: DefaultKey.firstLaunchToken.rawValue)
            defaults.synchronize()

            AuthorizedCLLocationManager.checkRequiredPlistValues(authorizationScope)

            let scope: AuthorizationScope = self.authorizationScope
            switch scope {
            case .whenInUse:
                manager.requestWhenInUseAuthorization()
                break
            case .always:
                manager.requestAlwaysAuthorization()
                break
            }
        }

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationCompletion(.success(manager))
            return
        case .denied:
            let defaults = UserDefaults.standard
            let appHasLaunchedAtLeastOnceBefore = defaults.bool(forKey: DefaultKey.firstLaunchToken.rawValue)
            if !appHasLaunchedAtLeastOnceBefore {
                requestPermission()
            } else {
                let error = NSError(domain: AuthorizationErrorDomain, code: AuthorizationErrorCode.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: AuthorizationErrorDescription, NSLocalizedFailureReasonErrorKey: "The user has denied location services for this app."])
                authorizationCompletion(.failure(error))
            }
            break
        case .notDetermined:
            requestPermission()
            break
        case .restricted:
            let error = NSError(domain: AuthorizationErrorDomain, code: AuthorizationErrorCode.restricted.rawValue, userInfo: [NSLocalizedDescriptionKey: AuthorizationErrorDescription, NSLocalizedFailureReasonErrorKey: "The user is not able to allow location services due to device restrictions."])
            authorizationCompletion(.failure(error))
            break
        @unknown default:
            fatalError("New unexpected authorization status encountered: \(status)")
        }
    }
    
}

private extension AuthorizedCLLocationManager {
    enum DefaultKey: String {
        case firstLaunchToken = "com.tworingsoft.can-i-haz.authorized-location-manager.user-defaults.key.first-launch-token"
    }

    func createAndAuthorizeNewLocationManager(_ scope: AuthorizationScope, completion: @escaping ((AuthorizedLocationManagerResult) -> Void)) {
        authorizationScope = scope

        self.authorizationCompletion = { authorizationResult in
            switch authorizationResult {
            case .success(let authorizedLocationManager):
                self.locationManager = nil
                authorizedLocationManager.delegate = nil
                completion(.success(authorizedLocationManager))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        // just by instantiating, we'll get a callback to `locationManager(_:didChangeAuthorization:)`
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }

    class func checkRequiredPlistValues(_ scope: AuthorizationScope) {
        var requiredPlistKey: String!
        switch scope {
        case .always:
            requiredPlistKey = "NSLocationAlwaysUsageDescription"
            break
        case .whenInUse:
            requiredPlistKey = "NSLocationWhenInUseUsageDescription"
            break
        }

        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Could not locate Info.plist keys and values.")
        }
        guard let requiredLocationRequestDescriptionValue = infoDictionary[requiredPlistKey] as? String else {
            fatalError("You must provide a value for \(String(describing: requiredPlistKey)) in your app's Info.plist for the location services request dialog to be shown to the user.")
        }
        if requiredLocationRequestDescriptionValue.count == 0 {
            fatalError("You provided a description value for \(String(describing: requiredPlistKey)) with length 0. This string is displayed to the user in the request prompt; consider providing more information why you are requesting location services.")
        }
    }
}
