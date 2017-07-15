//
//  CoreDataController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/16/17.
//
//

import CoreData

enum CoreDataError: Swift.Error {
    case entityContainsNoManagedObjectContext(String)
    case entityNotInserted(String)
    case cannotCreateEditingCopyOfEntity(String)
}

class CoreDataController: NSObject {

    private var modelName: String
    private var logger: LogController

    init(_ modelName: String, _ logger: LogController) {
        self.logger = logger
        self.modelName = modelName
        super.init()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        self.logger.logDebug(message: String(format: "[%@] About to load persistent store.", instanceType(self)))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.logger.logError(message: String(format: "[%@] Failed to load persistent store.", instanceType(self)), error: error)
            }
        })
        return container
    }()

}

// MARK: Access
extension CoreDataController {

    func perform(block: ((NSManagedObjectContext) -> Void)) {
        let context = persistentContainer.newBackgroundContext()
        logger.logDebug(message: String(format: "[%@] Vending new context <%@>.", instanceType(self), context))
        block(context)
    }

    func fetch<T>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext) -> [T] {
        var results = [T]()
        do {
            results.append(contentsOf: try context.fetch(request))
        } catch {
          let message = String(format: "[%@] Error executing fetch request <%@> on context <%@>.", instanceType(self), request, context)
            logger.logError(message: message, error: error)
        }
        return results
    }

    func exportData() -> Data {
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString

        let sqlitePath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite", Bundle.getAppName()))
        let sqliteWALPath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite-wal", Bundle.getAppName()))
        let sqliteSHMPath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite-shm", Bundle.getAppName()))

        var fileData = [String: NSData]()
        [ sqlitePath, sqliteWALPath, sqliteSHMPath ].forEach {
            guard let data = NSData(contentsOfFile: $0) else {
                logger.logWarning(message: String(format: "[%@] No data read from %@.", instanceType(self), $0))
                return
            }

            fileData[($0 as NSString).lastPathComponent] = data
        }

        return NSKeyedArchiver.archivedData(withRootObject: fileData)
    }

    func importData(data: Data) {
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: NSData] else {
            logger.logWarning(message: String(format: "[%@] Could not unarchive data to recover encoded databases.", instanceType(self)))
            return
        }

        fileData.forEach {
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
            let path = applicationSupportDirectory.appendingPathComponent($0.key)
            if !$0.value.write(toFile: path, atomically: true) {
                logger.logWarning(message: String(format: "[%@] Failed to write imported data to %@.", instanceType(self), $0.key))
            }
        }

        fatalError("Restarting to load new database.")
    }

}

// MARK: Persistence
extension CoreDataController {

    func save(context: NSManagedObjectContext) {
        logger.logDebug(message: String(format: "[%@] About to save changes to context <%@>.", instanceType(self), context))
        logger.logVerbose(message: String(format: "[%@] Changes:\ninserted: %@\ndeleted: %@\nupdated: %@, .", instanceType(self), context.insertedObjects, context.deletedObjects, context.updatedObjects))
        if !context.hasChanges {
            logger.logDebug(message: String(format: "[%@] No unsaved changes in context <%@>.", instanceType(self), context))
            return
        }

        do {
            try context.save()
        } catch {
            let message = String(format: "[%@] Could not save context <%@>.", instanceType(self), context)
            logger.logError(message: message, error: error)
        }
    }

}

// MARK: Deletion
extension CoreDataController {

    func delete(object: NSManagedObject, context: NSManagedObjectContext) {
        logger.logDebug(message: String(format: "[%@] About to delete object <%@> from context <%@>.", instanceType(self), object, context))
        context.delete(object)
        save(context: context)
    }
    
}
