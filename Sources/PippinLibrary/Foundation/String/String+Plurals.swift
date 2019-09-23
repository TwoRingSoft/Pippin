//
//  String+Plurals.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/26/18.
//

import Foundation

public extension String {
    func pluralized<T: Numeric>(forValue value: T) -> String {
        if value == 1 { return self }
        else { return self + "s" }
    }
}
