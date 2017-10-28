//
//  CoreDataController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/16/17.
//
//

import CoreData

enum CoreDataError: Swift.Error {
    case entityContainsNoManagedObjectContext(String)
    case entityNotInserted(String)
    case cannotCreateEditingCopyOfEntity(String)
    case entityNotDeleted(String)
}

class CoreDataController: NSObject {

    fileprivate var logger: Logger?
    fileprivate var modelName: String!

    override init() {
        self.modelName = Bundle.getAppName()
    }

    init(modelName: String) {
        self.modelName = modelName
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        self.logger?.logDebug(message: String(format: "[%@] About to load persistent store.", instanceType(self)))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.logger?.logError(message: String(format: "[%@] Failed to load persistent store.", instanceType(self)), error: error)
            }
        })
        return container
    }()

    func setLogger(logger: Logger) {
        self.logger = logger
    }

}

// MARK: Access
extension CoreDataController {

    func perform(block: ((NSManagedObjectContext) -> Void)) {
        let context = persistentContainer.newBackgroundContext()
        logger?.logDebug(message: String(format: "[%@] Vending new context <%@>.", instanceType(self), context))
        block(context)
    }

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
extension CoreDataController {

    typealias ConfirmBlock = ((Bool) -> ())
    typealias ConfirmCompletionBlock = ((Bool, @escaping ConfirmBlock) -> ())

    func exportData() -> Data {
        let sqlitePath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite", Bundle.getAppName()))
        let sqliteWALPath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite-wal", Bundle.getAppName()))
        let sqliteSHMPath = FileManager.url(forApplicationSupportFile: String(format: "%@.sqlite-shm", Bundle.getAppName()))

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

    func importFromSQLitePath(sqlitePath: String, completion: ConfirmCompletionBlock? = nil ) {
        let shmPath = sqlitePath.appending("-shm")
        let walPath = sqlitePath.appending("-wal")

        let data = archivedData(sqlitePath: sqlitePath, sqliteWALPath: walPath, sqliteSHMPath: shmPath)
        importData(data: data, completion: completion)
    }

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

    private func archivedData(sqlitePath: String, sqliteWALPath: String, sqliteSHMPath: String) -> Data {
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

// MARK: Persistence
extension CoreDataController {

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
extension CoreDataController {

    func delete(object: NSManagedObject, context: NSManagedObjectContext) {
        logger?.logDebug(message: String(format: "[%@] About to delete object <%@> from context <%@>.", instanceType(self), String(describing: object), context))
        context.delete(object)
        save(context: context)
    }
    
}
