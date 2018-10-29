//
//  ActivityIndicator.swift
//  Pippin
//
//  Created by Andrew McKnight on 5/24/18.
//

import Foundation

/// A protocol describing the functions needed to use an activity indicator–showing and hiding.
public protocol ActivityIndicator: Debuggable, Themeable, EnvironmentallyConscious {
    
    /// Display an activity indicator.
    ///
    /// - Parameters:
    ///   - text: Optional text to display in a label with the activity indicator.
    ///   - completion: An optional closure to execute when the indicator has been displayed.
    func show(withText text: String?, completion: EmptyBlock?)

    /// Display an activity indicator with attributed text.
    ///
    /// - Parameters:
    ///   - attributedText: Optional attributed text to display in a label with the activity indicator.
    ///   - completion: An optional closure to execute when the indicator has been displayed.
    func show(withAttributedText attributedText: NSAttributedString?, completion: EmptyBlock?)

    /// Hide any visible activity indicators.
    /// - Parameter completion: An optional closure to execute when the indicator has been dismissed.
    func hide(completion: EmptyBlock?)
}
