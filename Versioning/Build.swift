//
//  Build.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

typealias BuildNumber = UInt

struct Build {

    var number: BuildNumber

    static var zero = Build(number: 0)

}

extension Build: CustomStringConvertible {

    var description: String {
        return String(format: "%llu", number)
    }

}

extension Build: LosslessStringConvertible {

    init?(_ description: String) {
        number = description.unsignedIntegerValue
    }

}

extension Build: Equatable {}

func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.number == rhs.number
}

extension Build: Comparable {}

func <(lhs: Build, rhs: Build) -> Bool {
    return lhs.number < rhs.number
}

func <=(lhs: Build, rhs: Build) -> Bool {
    return lhs == rhs || lhs < rhs
}

func >(lhs: Build, rhs: Build) -> Bool {
    return !(lhs <= rhs)
}

func >=(lhs: Build, rhs: Build) -> Bool {
    return !(lhs < rhs)
}
