//
//  Environment.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Foundation

public struct Environment {

    public var appName: String!
    public var currentBuild: Build!
    public var semanticVersion: SemanticVersion!

    public var bugReporter: BugReporter!
    public var crashReporter: CrashReporter!
    public var debugFlowController: DebugFlowController!
    public var coreDataController: CoreDataController!
    public var logger: Logger!
    public var alerter: Alerter!

    public init() {}

}
