//
//  DebugMenuPresenter.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/22/19.
//

import Foundation

/// Protocol providing a single method for a conforming debugging utility to inject its UI at the time of calling.
public protocol DebugMenuPresenter: EnvironmentallyConscious {
    /// Installs debugging views and controls for any present Pippin components that supply them.
    /// - Parameter appControlPanel: optional views supplied by the app for debugging its business logic.
    func installViews(appControlPanel: UIView?)
}
