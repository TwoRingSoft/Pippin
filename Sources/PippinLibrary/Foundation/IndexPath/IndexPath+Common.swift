//
//  IndexPath+Common.swift
//  PippinTests
//
//  Created by Andrew McKnight on 3/18/17.
//
//

import Foundation

public extension IndexPath {
    static var zero: IndexPath {
        get {
            #if os(iOS)
            return IndexPath(row: 0, section: 0)
            #else
            return IndexPath(item: 0, section: 0)
            #endif
        }
    }
}
