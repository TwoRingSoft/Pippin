//
//  NSManagedObject+Factory.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/17/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import CoreData

extension NSManagedObject {

    /**
     - parameters:
         - name: the name of the entity type
         - context: the context in which to create a new entity
     - returns: new instance of a managed object of the specified entity type
     */
    class func entity<T>(named name: String, context: NSManagedObjectContext) throws -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as? T else {
            let message = String(format: "[%@] Could not insert %@ entity into context <%@>", classType(self), name, context)
            let error = CoreDataError.entityNotInserted(message)
            throw error
        }

        return entity
    }

}
