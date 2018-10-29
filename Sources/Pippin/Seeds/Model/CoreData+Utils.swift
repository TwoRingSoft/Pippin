//
//  CoreData+Utils.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/4/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import CoreData

extension NSFetchedResultsChangeType: CustomStringConvertible {

    /**
     - returns: human readable string representation of `NSFetchedResultsChangeType` case values
     */
    public var description: String {
        switch self {
            case .delete: return "delete"
            case .insert: return "insert"
            case .update: return "update"
            case .move: return "move"
        }
    }

}

extension NSFetchRequestResult {

    /**
     Convert an entity of type `NSFetchRequestResult` to the desired `NSManagedObject`
     subclass via generics.
     - Throws: if the object cannot be converted to the expected type.
     */
    public func convert<T>() throws -> T {
        guard let typedObject = self as? T else {
            throw CoreDataError.unexpectedEntityType(String(format: "Encountered object  %@ of unexpected type", String(reflecting: self)))
        }

        return typedObject
    }

}
