//
//  Model.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/13/18.
//

import Foundation
import SwiftArmcknight

#if canImport(UIKit)
public protocol Model: EnvironmentallyConscious, Debuggable {
    var modelName: String { get }
    func importFromSQLitePath(sqlitePath: String, completion: ConfirmCompletionBlock?)
    func importData(data: Data, completion: ConfirmCompletionBlock?)
    func exportData() throws -> Data
    #if DEBUG
    var debuggingDelegate: ModelDebugging? { get set }
    #endif
}
#else
public protocol Model: EnvironmentallyConscious {
    var modelName: String { get }
    func importFromSQLitePath(sqlitePath: String, completion: ConfirmCompletionBlock?)
    func importData(data: Data, completion: ConfirmCompletionBlock?)
    func exportData() throws -> Data
    #if DEBUG
    var debuggingDelegate: ModelDebugging? { get set }
    #endif
}
#endif

#if DEBUG
public protocol ModelDebugging {
    func exported(coreDataController: Model)
    func generateTestModels(coreDataController: Model)
    func deleteModels(coreDataController: Model)
    func importFixtures(coreDataController: Model)
}
#endif
