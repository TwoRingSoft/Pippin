//
//  Array+Description.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 12/18/21.
//

import Foundation

public extension Array where Element == Array<CustomStringConvertible> {
    var gridDescription: String {
        var string = String()
        for x in self {
            for y in x {
                string.append(y.description + " ")
            }
            string.append("\n")
        }
        return string
    }
}
