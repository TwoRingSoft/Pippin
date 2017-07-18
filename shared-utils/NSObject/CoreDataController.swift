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

    fileprivate static let singleton = CoreDataController()
    fileprivate var logger: LogController?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Bundle.getAppName())
        self.logger?.logDebug(message: String(format: "[%@] About to load persistent store.", instanceType(self)))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.logger?.logError(message: String(format: "[%@] Failed to load persistent store.", instanceType(self)), error: error)
            }
        })
        return container
    }()

    class func setLogger(logger: LogController) {
        singleton.logger = logger
    }

}

// MARK: Access
extension CoreDataController {

    class func perform(block: ((NSManagedObjectContext) -> Void)) {
        let context = singleton.persistentContainer.newBackgroundContext()
        singleton.logger?.logDebug(message: String(format: "[%@] Vending new context <%@>.", classType(self), context))
        block(context)
    }

    class func fetch<T>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext) -> [T] {
        var results = [T]()
        do {
            results.append(contentsOf: try context.fetch(request))
        } catch {
          let message = String(format: "[%@] Error executing fetch request <%@> on context <%@>.", classType(self), request, context)
            singleton.logger?.logError(message: message, error: error)
        }
        return results
    }

    class func exportData() -> Data {
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString

        let sqlitePath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite", Bundle.getAppName()))
        let sqliteWALPath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite-wal", Bundle.getAppName()))
        let sqliteSHMPath = applicationSupportDirectory.appendingPathComponent(String(format: "%@.sqlite-shm", Bundle.getAppName()))

        var fileData = [String: NSData]()
        [ sqlitePath, sqliteWALPath, sqliteSHMPath ].forEach {
            guard let data = NSData(contentsOfFile: $0) else {
                singleton.logger?.logWarning(message: String(format: "[%@] No data read from %@.", classType(self), $0))
                return
            }

            fileData[($0 as NSString).lastPathComponent] = data
        }

        return NSKeyedArchiver.archivedData(withRootObject: fileData)
    }

    class func importData(data: Data) {
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: NSData] else {
            singleton.logger?.logWarning(message: String(format: "[%@] Could not unarchive data to recover encoded databases.", classType(self)))
            return
        }

        fileData.forEach {
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
            let path = applicationSupportDirectory.appendingPathComponent($0.key)
            if !$0.value.write(toFile: path, atomically: true) {
                singleton.logger?.logWarning(message: String(format: "[%@] Failed to write imported data to %@.", classType(self), $0.key))
            }
        }

        fatalError("Restarting to load new database.")
    }

}

// MARK: Persistence
extension CoreDataController {

    class func save(context: NSManagedObjectContext) {
        singleton.logger?.logDebug(message: String(format: "[%@] About to save changes to context <%@>.", classType(self), context))
        singleton.logger?.logVerbose(message: String(format: "[%@] Changes:\ninserted: %@\ndeleted: %@\nupdated: %@, .", classType(self), context.insertedObjects, context.deletedObjects, context.updatedObjects))
        if !context.hasChanges {
            singleton.logger?.logDebug(message: String(format: "[%@] No unsaved changes in context <%@>.", classType(self), context))
            return
        }

        do {
            try context.save()
        } catch {
            let message = String(format: "[%@] Could not save context <%@>.", classType(self), context)
            singleton.logger?.logError(message: message, error: error)
        }
    }

}

// MARK: Deletion
extension CoreDataController {

    class func delete(object: NSManagedObject, context: NSManagedObjectContext) {
        singleton.logger?.logDebug(message: String(format: "[%@] About to delete object <%@> from context <%@>.", classType(self), object, context))
        context.delete(object)
        save(context: context)
    }
    
}
