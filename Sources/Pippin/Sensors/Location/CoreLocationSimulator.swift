//
//  CoreLocationSimulator.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/15/18.
//

import Anchorage
import CoreLocation
import Foundation

public class CoreLocationSimulator: NSObject, Locator {
    
    public var environment: Environment?
    private var locatorDelegate: LocatorDelegate
    private var locations: [CLLocation]?
    private var lastLocationID: Int?
    private let textView = UITextView(frame: .zero)
    private var delay: UInt32 = 0
    
    public required init(authorizedLocationManager: CLLocationManager?, locatorDelegate: LocatorDelegate) {
        self.locatorDelegate = locatorDelegate
        super.init()
    }
    
    public func setSimulatedLocations(locationsString: String) {
        self.locations = locationsString.components(separatedBy:EnvironmentVariable.simulatedLocationListDelimiter).compactMap { (locationString) -> CLLocation? in
            let coordinateComponents = locationString.components(separatedBy: EnvironmentVariable.simulatedLocationCoordinateDelimiter)
            let lat = coordinateComponents.first!
            let long = coordinateComponents.last!
            return CLLocation(latitude: lat.doubleValue, longitude: long.doubleValue)
        }
    }
    
    public func setSimulatedLocationDelay(delay: UInt32) {
        self.delay = delay
    }
    
    public func startMonitoringLocation() {
        guard let locations = locations else {
            fatalError("Tried to use CoreLocationSimulator without provided any simulated locations. Use the environment variable.")
        }
        let location = locations[(lastLocationID ?? 0) % locations.count]
        sleep(delay)
        locatorDelegate.locator(locator: self, updatedToLocation: location)
    }
    
    public func stopMonitoringLocation() {
        // noop
    }
}

// MARK: Debuggable
extension CoreLocationSimulator: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let titleLabel = UILabel.label(withText: "Locator:", font: environment!.fonts.title, textColor: .black)
        let button = UIButton(type: .custom)
        button.configure(title: "Next location", target: self, selector: #selector(nextLocationPressed))
        reloadDebuggingTextView()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, textView, button])
        stack.axis = .vertical
        textView.heightAnchor == 100
        return stack
    }
    
    private func reloadDebuggingTextView() {
        var i = 0
        textView.text = locations?.map {
            let string = "\(lastLocationID ?? 0 == i ? "* " : "")\(i): lat: \($0.coordinate.latitude), long: \($0.coordinate.longitude)"
            i += 1
            return string
            }.joined(separator: "\n")
    }
    
    @objc private func nextLocationPressed() {
        guard let locations = locations else {
            fatalError("Tried to use CoreLocationSimulator without provided any simulated locations. Use the environment variable.")
        }
        if let lastLocationID = lastLocationID {
            locatorDelegate.locator(locator: self, updatedToLocation: locations[(lastLocationID + 1) % locations.count])
            self.lastLocationID? += 1
        } else {
            locatorDelegate.locator(locator: self, updatedToLocation: locations[1])
            self.lastLocationID = 1
        }
        reloadDebuggingTextView()
    }
}
