//
//  NSManagedObject+Factory.swift
//  shared-utils
//
//  Created by Andrew McKnight on 7/17/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import CoreData

extension NSManagedObject {

    class func entity<T>(named name: String, context: NSManagedObjectContext) throws -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as? T else {
            let message = String(format: "[%@] Could not insert %@ entity into context <%@>", classType(self), name, context)
            let error = CoreDataError.entityNotInserted(message)
            throw error
        }

        return entity
    }

}
