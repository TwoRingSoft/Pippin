//
//  Debuggable.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/18/18.
//

import Foundation

/// For protocols that touch UI, conformers provide a `UIView` containing controls a tester can manipulate to exercise the protocol API and view a representative collection of UI states.
public protocol Debuggable {
    func debuggingControlPanel() -> UIView
}
