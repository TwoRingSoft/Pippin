//
//  CoreDataController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/16/17.
//
//

import CoreData

/**
 A closure that accepts a boolean parameter.
 */
public typealias ConfirmBlock = ((_ confirmed: Bool) -> ())

/**
 A closure that accepts a boolean representing if an operation completed
 successfully, to decide whether to retrieve confirmation from
 `confirmBlock`.

 This provides a way for a consumer application to provide custom UI/UX
 before returning control here to e.g. kill the app to reload a debug
 database.
 */
public typealias ConfirmCompletionBlock = ((_ success: Bool, _ confirmBlock: @escaping ConfirmBlock) -> ())

/**
 A class providing convenience API to work with Apple's Core Data.
 */
public class CoreDataController: NSObject {

    fileprivate var logger: Logger?
    var modelName: String!
    fileprivate var managedObjectModel: NSManagedObjectModel?

    /**
     Initialize a new Core Data helper.
     - Note: this function computes the app name from the bundle to determine
     the model name.
     - parameter modelName: the model to initialize for core data
     */
    public init(modelName: String) {
        self.modelName = modelName
    }

    /**
     Initialize a new Core Data helper.
     - parameters:
        - modelName: name of the managed object model to load
        - managedObjectModel: optional instance passed in if the momd file is
        is delivered from a nonstandard location, like a framework
        - logger: optional `Logger` conforming instance, defaults to `nil`
     */
    public init(modelName: String, managedObjectModel: NSManagedObjectModel? = nil, logger: Logger? = nil) {
        self.logger = logger
        self.modelName = modelName
        self.managedObjectModel = managedObjectModel
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        var container: NSPersistentContainer
        if let managedObjectModel = managedObjectModel {
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        self.logger?.logDebug(message: String(format: "[%@] About to load persistent store.", instanceType(self)))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.logger?.logError(message: String(format: "[%@] Failed to load persistent store.", instanceType(self)), error: error)
            }
        })
        return container
    }()

}

// MARK: Access
public extension CoreDataController {

    /**
     Get a context to perform some work with in a closure, without having to
     worry about managing it.
     - parameter block: a closure accepting a `NSManagedObjectContext` parameter
     */
    func perform(block: ((NSManagedObjectContext) -> Void)) {
        let context = persistentContainer.newBackgroundContext()
        logger?.logDebug(message: String(format: "[%@] Vending new context <%@>.", instanceType(self), context))
        block(context)
    }

    /**
     Returns a typed array of entities fetched, and provides some boilerplate error handling.
     - parameters:
         - request: the fetch request to perform, generic on the type of results
         - context: the context to fetch from
     - returns: array populated with the results of the fetch request
     */
    func fetch<T>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext) -> [T] {
        var results = [T]()
        do {
            results.append(contentsOf: try context.fetch(request))
        } catch {
          let message = String(format: "[%@] Error executing fetch request <%@> on context <%@>.", instanceType(self), request, context)
            logger?.logError(message: message, error: error)
        }
        return results
    }

}

// MARK: Import/Export
public extension CoreDataController {

    /**
     Import data from archived data on disk into Core Data.
     - parameters:
         - sqlitePath: path to the database on disk
         - completion: the confirming completion block, allowing the consumer
            app to acquire permission to restart
     */
    func importFromSQLitePath(sqlitePath: String, completion: ConfirmCompletionBlock? = nil ) {
        let shmPath = sqlitePath.appending("-shm")
        let walPath = sqlitePath.appending("-wal")

        let data = archivedData(sqlitePath: sqlitePath, sqliteWALPath: walPath, sqliteSHMPath: shmPath)
        importData(data: data, completion: completion)
    }

    /**
     Import data in memory to Core Data.
     - parameters:
         - data: the `Data` instance to unarchive
         - completion: the confirming completion block, allowing the consumer
             app to acquire permission to restart
     */
    func importData(data: Data, completion: ConfirmCompletionBlock? = nil) {
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: NSData] else {
            logger?.logWarning(message: String(format: "[%@] Could not unarchive data to recover encoded databases.", instanceType(self)))
            return
        }

        var success = true
        fileData.forEach {
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
            let path = applicationSupportDirectory.appendingPathComponent($0.key)
            if !$0.value.write(toFile: path, atomically: true) {
                logger?.logWarning(message: String(format: "[%@] Failed to write imported data to %@.", instanceType(self), $0.key))
                success = false
            }
        }

        completion?(success, { confirm in
            if confirm {
                fatalError("Restarting to load new database.")
            }
        })
    }

    /**
     Export data.
     - returns: `Data` object containing `NSKeyedArchiver` archived data from
     the array: `[db.sqlite, db.sqlite-wal, db.sqlite-shm]`, where each item is
     the raw `Data` from each of those files.
     */
    func exportData() -> Data {
        let sqlitePath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite", modelName))
        let sqliteWALPath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite-wal", modelName))
        let sqliteSHMPath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite-shm", modelName))

        var fileData = [String: NSData]()
        [ sqlitePath, sqliteWALPath, sqliteSHMPath ].forEach {
            guard let data = NSData(contentsOf: $0) else {
                logger?.logWarning(message: String(format: "[%@] No data read from %@.", instanceType(self), String(describing: $0)))
                return
            }

            fileData[$0.lastPathComponent] = data
        }

        return NSKeyedArchiver.archivedData(withRootObject: fileData)
    }

}

// MARK: Persistence
public extension CoreDataController {

    /**
     Save any outstanding changes to a context, logging any changes and errors.
     - parameter context: the context to save changes in.
     */
    func save(context: NSManagedObjectContext) {
        logger?.logDebug(message: String(format: "[%@] About to save changes to context <%@>.", instanceType(self), context))
        logger?.logVerbose(message: String(format: "[%@] Changes:\ninserted: %@\ndeleted: %@\nupdated: %@, .", instanceType(self), context.insertedObjects, context.deletedObjects, context.updatedObjects))
        if !context.hasChanges {
            logger?.logDebug(message: String(format: "[%@] No unsaved changes in context <%@>.", instanceType(self), context))
            return
        }

        do {
            try context.save()
        } catch {
            let message = String(format: "[%@] Could not save context <%@>.", instanceType(self), context)
            logger?.logError(message: message, error: error)
        }
    }

}

// MARK: Deletion
public extension CoreDataController {

    /**
     Delete an entity from a context and save the change.
     - parameters:
     - object: the object to delete
     - context: the context from which to remove the object
     */
    func delete(object: NSManagedObject, context: NSManagedObjectContext) {
        logger?.logDebug(message: String(format: "[%@] About to delete object <%@> from context <%@>.", instanceType(self), String(describing: object), context))
        context.delete(object)
        save(context: context)
    }
    
}

private extension CoreDataController {

    func archivedData(sqlitePath: String, sqliteWALPath: String, sqliteSHMPath: String) -> Data {
        var fileData = [String: NSData]()
        [ sqlitePath, sqliteWALPath, sqliteSHMPath ].forEach {
            guard let data = NSData(contentsOfFile: $0) else {
                logger?.logWarning(message: String(format: "[%@] No data read from %@.", instanceType(self), $0))
                return
            }

            fileData[($0 as NSString).lastPathComponent] = data
        }

        return NSKeyedArchiver.archivedData(withRootObject: fileData)
    }

}
