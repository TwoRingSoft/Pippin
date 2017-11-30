//
//  CoreDataError.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/29/17.
//

import Foundation

/**
 Error enum describing problems that may arise when working with data model
 persistence.
 */
public enum CoreDataError: Swift.Error {

    /**
     An entity was acquired that has no reference to a managed object context.
     */
    case entityContainsNoManagedObjectContext(String)

    /**
     Failed to create a new entity into a context.
     */
    case entityNotInserted(String)

    /**
     Failed to create scratch copy of entity to edit using a scratch context.
     */
    case cannotCreateEditingCopyOfEntity(String)

    /**
     Failed to delete an entity.
     */
    case entityNotDeleted(String)
}
