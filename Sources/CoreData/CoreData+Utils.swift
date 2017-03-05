//
//  CoreData+Utils.swift
//  shared-utils
//
//  Created by Andrew McKnight on 3/4/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import CoreData

func name(forFetchedResultsChangeType type: NSFetchedResultsChangeType) -> String {
    switch type {
    case .delete:
        return "delete"
    case .insert:
        return "insert"
    case .update:
        return "update"
    case .move:
        return "move"
    }
}
