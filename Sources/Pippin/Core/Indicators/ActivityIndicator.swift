//
//  ActivityIndicator.swift
//  Pippin
//
//  Created by Andrew McKnight on 5/24/18.
//

import Foundation

/// A protocol describing the functions needed to use an activity indicator–showing and hiding.
public protocol ActivityIndicator {

    /// Display an activity indicator.
    ///
    /// - Parameter text: optional text to display in a label with the activity indicator.
    func show(withText text: String?)

    /// Hide any visible activity indicators.
    func hide()
}
