//
//  Themeable.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/27/18.
//

import Foundation

/// Protocol that tags another protocol/class/struct as being able to return a view hierarchy to use in `appearance(whenContainedInInstancesOf:)`. Caller must know the `UIView` subclass that is receiving appearance treatment.
public protocol Themeable {
    func appearanceContainerClassHierarchy() -> [UIAppearanceContainer.Type]
}
