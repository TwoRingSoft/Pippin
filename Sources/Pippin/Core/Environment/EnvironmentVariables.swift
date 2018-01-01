//
//  EnvironmentVariables.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

public enum EnvironmentVariable: String {

    case logLevel = "log-level"

    public func value() -> String? {
        return ProcessInfo.processInfo.environment[String(describing: self)] as String?
    }

}

extension EnvironmentVariable: CustomStringConvertible {

    public var description: String {
        return String(asRDNSForPippinSubpaths: [ "environment-variable", rawValue ])
    }

}
