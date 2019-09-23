//
//  Set+Equality.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/30/18.
//

import Foundation

public extension Set {
    func containsSameElements(as set: Set) -> Bool {
        let difference = symmetricDifference(set)
        return difference.count == 0
    }
}
