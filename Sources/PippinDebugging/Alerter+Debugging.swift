//
//  Alerter+Debugging.swift
//  AFDateHelper
//
//  Created by Andrew McKnight on 3/1/19.
//

#if canImport(UIKit)
import Foundation
import Pippin

public extension Alerter {
    func showFeatureUnavailableOnSimulatorAlert() {
        showAlert(title: "Dev Error", message: "Feature not available on simulator", type: .error, dismissal: .automatic, occlusion: .weak)
    }
}
#endif
