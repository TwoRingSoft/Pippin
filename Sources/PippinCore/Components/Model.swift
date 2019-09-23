//
//  Model.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/13/18.
//

import Foundation
import PippinLibrary

/// Protocol describing the model infrastructure, that is, the software stack managing state from persistence to in-memory. In Apple, this is CoreData. This is not related to the definition of the schema used in a consuming app. Rather a `Model` is used to manage the data written in the schema defined in that app.
public protocol Model: Debuggable, EnvironmentallyConscious {
    func importFromSQLitePath(sqlitePath: String, completion: ConfirmCompletionBlock?)
    func importData(data: Data, completion: ConfirmCompletionBlock?)
    func exportData() throws -> Data
}
