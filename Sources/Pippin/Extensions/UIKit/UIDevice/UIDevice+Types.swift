//
//  UIDevice+Types.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/4/18.
//

import Foundation

public extension UIDevice {

    class func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

}
