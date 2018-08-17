//
//  CoreLocationSimulator.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/15/18.
//

import CoreLocation
import Foundation

/// A tuple with a location id number, `CLLocation` and a `TimeInterval` representing the amount of time spent at that location.
public typealias LocationAndTimeOffset = (locationID: Int, location: CLLocation, timeInterval: TimeInterval)

typealias TimerUserInfo = [String: Int]
enum TimerUserInfoKey: String {
    case lastLocationID
}

public class CoreLocationSimulator: NSObject, Locator {
    
    public var environment: Environment?
    private var locatorDelegate: LocatorDelegate
    public var locationsAndTimeOffsets: [LocationAndTimeOffset]?
    private var timer: Timer?
    
    public required init(authorizedLocationManager: CLLocationManager?, locatorDelegate: LocatorDelegate) {
        self.locatorDelegate = locatorDelegate
        super.init()
    }
    
    public func startMonitoringLocation() {
        guard let firstLocation = locationsAndTimeOffsets?.first else {
            // TODO: error
            return
        }
        startTimer(forLocation: firstLocation)
    }
    
    public func stopMonitoringLocation() {
        
    }
    
    @objc private func timerFired(timer: Timer) {
        guard let userInfo = timer.userInfo as? TimerUserInfo, let lastLocationID = userInfo[TimerUserInfoKey.lastLocationID.rawValue] as Int? else {
            // TODO: error
            return
        }
        
        if let nextLocation = locationsAndTimeOffsets?.filter({ (locationAndTimeOffset) -> Bool in
            locationAndTimeOffset.locationID == lastLocationID + 1
        }).first {
            startTimer(forLocation: nextLocation)
        }
    }
    
    private func startTimer(forLocation location: LocationAndTimeOffset) {
        let userInfo: TimerUserInfo = [TimerUserInfoKey.lastLocationID.rawValue: location.locationID]
        timer = Timer(timeInterval: location.timeInterval, target: self, selector: #selector(timerFired(timer:)), userInfo: userInfo, repeats: false)
        
    }
}
