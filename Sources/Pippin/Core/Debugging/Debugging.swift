//
//  Debugging.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/18/18.
//

import Foundation

public enum DebugFlowError: Error {
    case databaseExportError(message: String, underlyingError: Error)
    case noAppsToImportDatabase
}

public protocol Debugging {
    func installViews()
}

public protocol DebuggingDelegate {
    func exportedDatabaseData() -> Data?
    func failedToExportDatabase(error: DebugFlowError)
    func debugFlowControllerWantsToGenerateTestModels(debugFlowController: Debugging)
}
