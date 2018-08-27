//
//  CoreDataController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/16/17.
//
//

import CoreData

/**
 A closure that accepts a boolean representing if an operation completed
 successfully, to decide whether to retrieve confirmation from
 `confirmBlock`.

 This provides a way for a consumer application to provide custom UI/UX
 before returning control here to e.g. kill the app to reload a debug
 database.
 */
public typealias ConfirmCompletionBlock = ((_ success: Bool, _ confirmBlock: @escaping BooleanBlock) -> ())

/**
 A class providing convenience API to work with Apple's Core Data.
 */
public class CoreDataController: NSObject, EnvironmentallyConscious {

    public var environment: Environment?
    var modelName: String
    fileprivate var managedObjectModel: NSManagedObjectModel?
    public var debuggingDelegate: CoreDataControllerDebugging?

    /**
     Initialize a new Core Data helper.
     - parameters:
        - modelName: name of the managed object model to load
        - managedObjectModel: optional instance passed in if the momd file is
        is delivered from a nonstandard location, like a framework
        - logger: optional `Logger` conforming instance, defaults to `nil`
     */
    public init(modelName: String, managedObjectModel: NSManagedObjectModel? = nil) {
        self.modelName = modelName
        self.managedObjectModel = managedObjectModel
        super.init()
    }

    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        var container: NSPersistentContainer
        if let managedObjectModel = managedObjectModel {
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        self.environment?.logger.logDebug(message: String(format: "[%@] About to load persistent store.", instanceType(self)))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.environment?.logger.logError(message: String(format: "[%@] Failed to load persistent store.", instanceType(self)), error: error)
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
    @available(iOS 10.0, *)
    func perform(block: ((NSManagedObjectContext) -> Void)) {
        let context = persistentContainer.newBackgroundContext()
        environment?.logger.logDebug(message: String(format: "[%@] Vending new context <%@>.", instanceType(self), context))
        block(context)
    }
    
    @available(iOS 10.0, *)
    func context() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    /**
     Returns a typed array of entities fetched, and provides some boilerplate error handling.
     - parameters:
         - request: the fetch request to perform, generic on the type of results
     - context: the context to fetch from. If none is provided, a new context is vendored.
     - returns: array populated with the results of the fetch request
     */
    @available(iOS 10.0, *)
    func fetch<T>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) -> [T] {
        var results = [T]()
        let resolvedContext = context ?? self.context()
        do {
            results.append(contentsOf: try resolvedContext.fetch(request))
        } catch {
          let message = String(format: "[%@] Error executing fetch request <%@> on context <%@>.", instanceType(self), request, resolvedContext)
            environment?.logger.logError(message: message, error: error)
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
            environment?.logger.logWarning(message: String(format: "[%@] Could not unarchive data to recover encoded databases.", instanceType(self)))
            return
        }

        var success = true
        fileData.forEach {
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
            let path = applicationSupportDirectory.appendingPathComponent($0.key)
            if !$0.value.write(toFile: path, atomically: true) {
                environment?.logger.logWarning(message: String(format: "[%@] Failed to write imported data to %@.", instanceType(self), $0.key))
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
                environment?.logger.logWarning(message: String(format: "[%@] No data read from %@.", instanceType(self), String(describing: $0)))
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
     Save any outstanding changes to a context, logging any changes and errors. If no context is provided, then all changes to the underlying model are saved via a new vendored context.
     - parameter context: the context to save changes in.
     */
    @available(iOS 10.0, *)
    func save(context: NSManagedObjectContext? = nil) {
        let resolvedContext = context ?? self.context()
        environment?.logger.logDebug(message: String(format: "[%@] About to save changes to context <%@>.", instanceType(self), resolvedContext))
        environment?.logger.logVerbose(message: String(format: "[%@] Changes:\ninserted: %@\ndeleted: %@\nupdated: %@, .", instanceType(self), resolvedContext.insertedObjects, resolvedContext.deletedObjects, resolvedContext.updatedObjects))
        if !resolvedContext.hasChanges {
            environment?.logger.logDebug(message: String(format: "[%@] No unsaved changes in context <%@>.", instanceType(self), resolvedContext))
            return
        }
        
        do {
            try resolvedContext.save()
        } catch {
            let message = String(format: "[%@] Could not save context <%@>.", instanceType(self), resolvedContext)
            environment?.logger.logError(message: message, error: error)
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
    @available(iOS 10.0, *)
    func delete(object: NSManagedObject, context: NSManagedObjectContext) {
        environment?.logger.logDebug(message: String(format: "[%@] About to delete object <%@> from context <%@>.", instanceType(self), String(describing: object), context))
        context.delete(object)
        save(context: context)
    }
    
}

private extension CoreDataController {

    func archivedData(sqlitePath: String, sqliteWALPath: String, sqliteSHMPath: String) -> Data {
        var fileData = [String: NSData]()
        [ sqlitePath, sqliteWALPath, sqliteSHMPath ].forEach {
            guard let data = NSData(contentsOfFile: $0) else {
                environment?.logger.logWarning(message: String(format: "[%@] No data read from %@.", instanceType(self), $0))
                return
            }

            fileData[($0 as NSString).lastPathComponent] = data
        }

        return NSKeyedArchiver.archivedData(withRootObject: fileData)
    }

}
