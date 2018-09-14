//
//  UserDefaults+SetAndSync.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/13/18.
//

import Foundation

public extension UserDefaults {
    class func setAndSynchronize(key: String, value: Any?) {
        standard.set(value, forKey: key)
        standard.synchronize()
    }
}
