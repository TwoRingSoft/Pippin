//
//  Build.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

typealias BuildNumber = UInt

public struct Build {

    var number: BuildNumber

    public static var zero = Build(number: 0)

}

extension Build: CustomStringConvertible {

    public var description: String {
        return String(format: "%llu", number)
    }

}

extension Build: LosslessStringConvertible {

    public init?(_ description: String) {
        number = description.unsignedIntegerValue
    }

}

extension Build: Equatable {}

public func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.number == rhs.number
}

extension Build: Comparable {}

public func <(lhs: Build, rhs: Build) -> Bool {
    return lhs.number < rhs.number
}

public func <=(lhs: Build, rhs: Build) -> Bool {
    return lhs == rhs || lhs < rhs
}

public func >(lhs: Build, rhs: Build) -> Bool {
    return !(lhs <= rhs)
}

public func >=(lhs: Build, rhs: Build) -> Bool {
    return !(lhs < rhs)
}
