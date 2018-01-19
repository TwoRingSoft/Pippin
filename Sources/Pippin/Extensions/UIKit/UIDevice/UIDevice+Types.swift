//
//  UIDevice+Types.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/4/18.
//

import Foundation

extension UIDevice {

    class func isSimulator() -> Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #else
            return false
        #endif
    }

}
