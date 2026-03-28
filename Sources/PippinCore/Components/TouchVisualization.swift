//
//  TouchVisualization.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/14/18.
//

#if canImport(UIKit)
import Foundation

public protocol TouchVisualization: EnvironmentallyConscious, Debuggable {
    func installViews()
}
#endif
