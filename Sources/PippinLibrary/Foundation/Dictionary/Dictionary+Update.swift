//
//  Dictionary+Update.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/16/19.
//

import Foundation

public extension Dictionary {
    /// Insert a value for a key, or if there's already a value for the key, allow a way to update that value.
    ///
    /// - Parameter block: logic to perform the necessary transoformation of a preexisting value if it exists in the dictionary for `key`.
    mutating func insert(value: Value, forKey key: Key, orUpdateWithBlock block: ((Value) -> Value)) {
        if let currentValue = self[key] {
            self[key] = block(currentValue)
        } else {
            self[key] = value
        }
    }
}
