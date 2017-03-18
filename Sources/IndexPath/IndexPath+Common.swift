//
//  IndexPath+Common.swift
//  shared-utils-tests
//
//  Created by Andrew McKnight on 3/18/17.
//
//

import Foundation

extension IndexPath {

    static var zero: IndexPath {
        get {
            return IndexPath(row: 0, section: 0)
        }
    }

}
