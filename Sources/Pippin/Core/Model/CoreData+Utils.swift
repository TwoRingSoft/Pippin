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
