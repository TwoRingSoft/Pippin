//
//  Debugging.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/18/18.
//

import Foundation

/// Protocol providing a single method for a conforming debugging utility to inject its UI at the time of calling.
public protocol Debugging: EnvironmentallyConscious {
    func installViews()
}

/// For protocols that touch UI, conformers provide a `UIView` containing controls a tester can manipulate to exercise the protocol API and view a representative collection of UI states.
public protocol Debuggable {
    func debuggingControlPanel() -> UIView
}
