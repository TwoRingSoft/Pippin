import CoreData
import CloudKit
import Pippin

public final class CloudKitCoreDataController: NSObject, @unchecked Sendable {
    public var environment: Environment? {
        didSet { startObservingCloudKitEvents() }
    }
    public let container: NSPersistentCloudKitContainer
    public let cloudKitContainer: CKContainer
    public let modelName: String

    private let privatePersistentStoreURL: URL
    private let sharedPersistentStoreURL: URL
    private var eventObserver: NSObjectProtocol?
    private var pendingErrors: [String: Error] = [:]


    public init(modelName: String, cloudKitContainerIdentifier: String, managedObjectModel: NSManagedObjectModel, inMemory: Bool, initializeCloudKitSchema: Bool, resetSharedStore: Bool) {
        self.modelName = modelName
        container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: managedObjectModel)
        cloudKitContainer = CKContainer(identifier: cloudKitContainerIdentifier)

        let baseURL = NSPersistentContainer.defaultDirectoryURL()
        privatePersistentStoreURL = baseURL.appendingPathComponent("\(modelName)-private.sqlite")
        sharedPersistentStoreURL = baseURL.appendingPathComponent("\(modelName)-shared.sqlite")

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        } else {
            let privateDescription = NSPersistentStoreDescription(url: privatePersistentStoreURL)
            privateDescription.configuration = "Default"
            let privateOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: cloudKitContainerIdentifier
            )
            privateOptions.databaseScope = .private
            privateDescription.cloudKitContainerOptions = privateOptions
            privateDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            privateDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            privateDescription.shouldMigrateStoreAutomatically = true
            privateDescription.shouldInferMappingModelAutomatically = true

            let sharedDescription = NSPersistentStoreDescription(url: sharedPersistentStoreURL)
            sharedDescription.configuration = "Shared"
            let sharedOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: cloudKitContainerIdentifier
            )
            sharedOptions.databaseScope = .shared
            sharedDescription.cloudKitContainerOptions = sharedOptions
            sharedDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            sharedDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            sharedDescription.shouldMigrateStoreAutomatically = true
            sharedDescription.shouldInferMappingModelAutomatically = true

            container.persistentStoreDescriptions = [privateDescription, sharedDescription]
        }

        super.init()

        if resetSharedStore {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try coordinator.destroyPersistentStore(at: sharedPersistentStoreURL, type: .sqlite)
            } catch {
                pendingErrors["resetSharedStore"] = error
            }
        }

        container.loadPersistentStores { [weak self] description, error in
            if let error {
                self?.environment?.logger?.logError(
                    message: "Core Data store failed to load (\(description.url?.lastPathComponent ?? "unknown"))",
                    error: error
                )
            } else {
                let scope = description.cloudKitContainerOptions?.databaseScope == .shared ? "shared" : "private"
                self?.environment?.logger?.logInfo(
                    message: "Core Data store loaded (\(scope): \(description.url?.lastPathComponent ?? "unknown"), storeIdentifier: \(description.cloudKitContainerOptions?.containerIdentifier ?? "none"))"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        if initializeCloudKitSchema {
            do {
                try container.initializeCloudKitSchema(options: [])
                environment?.logger?.logInfo(message: "CloudKit schema initialization succeeded")
            } catch {
                environment?.logger?.logError(message: "CloudKit schema initialization failed", error: error)
            }
        }
    }

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    public var privatePersistentStore: NSPersistentStore? {
        container.persistentStoreCoordinator.persistentStore(for: privatePersistentStoreURL)
    }

    public var sharedPersistentStore: NSPersistentStore? {
        container.persistentStoreCoordinator.persistentStore(for: sharedPersistentStoreURL)
    }

    /// Fetches the current iCloud user record ID and reports it to the environment's crash reporter as the user identifier.
    /// The record ID is a stable per-container hash of the user's iCloud account; it is not personally identifying.
    public func reportiCloudUserToCrashReporter() {
        cloudKitContainer.fetchUserRecordID { [weak self] recordID, error in
            guard let self else { return }
            if let error {
                self.environment?.logger?.logError(message: "Failed to fetch iCloud user record ID", error: error)
                return
            }
            guard let recordID else { return }
            DispatchQueue.main.async {
                self.environment?.crashReporter?.setUser(id: recordID.recordName, username: nil, email: nil)
                self.environment?.logger?.logInfo(message: "Reported iCloud user record ID to crash reporter: \(recordID.recordName)")
            }
        }
    }

    private func storeName(for storeIdentifier: String) -> String {
        if let store = privatePersistentStore, store.identifier == storeIdentifier {
            return "private (\(store.url?.lastPathComponent ?? storeIdentifier))"
        }
        if let store = sharedPersistentStore, store.identifier == storeIdentifier {
            return "shared (\(store.url?.lastPathComponent ?? storeIdentifier))"
        }
        return storeIdentifier
    }

    private func logCurrentCoreDataContents() {
        let entityNames = container.managedObjectModel.entities.map { $0.name ?? "unnamed" }
        var summary: [String] = []
        for entityName in entityNames {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            if let results = try? container.viewContext.fetch(request) {
                summary.append("\(entityName): \(results.count)")
            }
        }
        environment?.logger?.logDebug(message: "Core Data contents after import — \(summary.joined(separator: ", "))")
    }

    private func logShareStatus() {
        let stores: [(NSPersistentStore?, String)] = [
            (privatePersistentStore, "private"),
            (sharedPersistentStore, "shared"),
        ]
        for (store, label) in stores {
            guard let store else {
                environment?.logger?.logDebug(message: "Share status: \(label) store not available")
                continue
            }
            do {
                let shares = try container.fetchShares(in: store)
                if shares.isEmpty {
                    environment?.logger?.logDebug(message: "Share status: \(label) store — no shares")
                } else {
                    for share in shares {
                        let participants = share.participants.map { "\($0.userIdentity.nameComponents?.formatted() ?? "unknown") [\($0.role == .owner ? "owner" : "participant"), \($0.acceptanceStatus == .accepted ? "accepted" : "pending")]" }
                        environment?.logger?.logInfo(message: "Share status: \(label) store — share \(share.recordID.recordName), participants: \(participants)")
                    }
                }
            } catch {
                environment?.logger?.logError(message: "Share status: failed to fetch shares from \(label) store", error: error)
            }
        }
    }

    private func startObservingCloudKitEvents() {
        for (key, error) in pendingErrors {
            environment?.logger?.logError(message: "Deferred error from init (\(key))", error: error)
            environment?.crashReporter?.recordNonfatalError(error: error, metadata: ["init.phase": key])
        }
        pendingErrors.removeAll()

        logShareStatus()

        if let eventObserver {
            NotificationCenter.default.removeObserver(eventObserver)
        }
        eventObserver = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: container,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else { return }

            let typeName: String
            switch event.type {
            case .setup: typeName = "setup"
            case .import: typeName = "import"
            case .export: typeName = "export"
            @unknown default: typeName = "unknown"
            }

            let storeName = self.storeName(for: event.storeIdentifier)

            guard event.endDate != nil else {
                self.environment?.logger?.logDebug(
                    message: "CloudKit \(typeName) event started (store: \(storeName))"
                )
                return
            }

            if let error = event.error {
                let nsError = error as NSError
                var metadata: [String: Any] = [
                    "cloudkit.event.type": typeName,
                    "cloudkit.event.store": storeName,
                    "cloudkit.event.identifier": event.identifier.uuidString,
                    "cloudkit.error.domain": nsError.domain,
                    "cloudkit.error.code": nsError.code,
                    "cloudkit.error.description": nsError.localizedDescription,
                    "cloudkit.error.debugDescription": nsError.debugDescription,
                    "cloudkit.error.userInfo": String(reflecting: nsError.userInfo),
                ]

                if let failureReason = nsError.localizedFailureReason {
                    metadata["cloudkit.error.failureReason"] = failureReason
                }
                if let recoverySuggestion = nsError.localizedRecoverySuggestion {
                    metadata["cloudkit.error.recoverySuggestion"] = recoverySuggestion
                }
                if let helpAnchor = nsError.helpAnchor {
                    metadata["cloudkit.error.helpAnchor"] = helpAnchor
                }
                for (key, value) in nsError.userInfo {
                    let keyString = String(describing: key)
                    // Skip keys we've already captured or that are huge nested errors we handle separately
                    if keyString == NSUnderlyingErrorKey || keyString == "CKErrorPartialErrorsByItemIDKey" {
                        continue
                    }
                    metadata["cloudkit.error.userInfo.\(keyString)"] = String(describing: value)
                }

                // Walk the underlying error chain
                var underlyingErrors: [String] = []
                var currentError: NSError? = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
                var depth = 0
                while let underlying = currentError, depth < 10 {
                    underlyingErrors.append("\(underlying.domain) code=\(underlying.code): \(underlying.localizedDescription) userInfo=\(String(reflecting: underlying.userInfo))")
                    currentError = underlying.userInfo[NSUnderlyingErrorKey] as? NSError
                    depth += 1
                }
                if !underlyingErrors.isEmpty {
                    metadata["cloudkit.error.underlyingChain"] = underlyingErrors.joined(separator: "\n---\n")
                }

                if let partialErrors = nsError.userInfo[CKPartialErrorsByItemIDKey] as? [AnyHashable: Error] {
                    let partialDescriptions = partialErrors.map { key, value in
                        let partial = value as NSError
                        return "\(key): \(partial.domain) code=\(partial.code) \(partial.localizedDescription) userInfo=\(String(reflecting: partial.userInfo))"
                    }.joined(separator: "\n")
                    metadata["cloudkit.error.partialErrors"] = partialDescriptions
                }

                self.environment?.logger?.logError(
                    message: "CloudKit \(typeName) event failed (store: \(event.storeIdentifier)) — \(metadata)",
                    error: error
                )
                self.environment?.crashReporter?.recordNonfatalError(
                    error: error,
                    metadata: metadata
                )


            } else {
                self.environment?.logger?.logDebug(
                    message: "CloudKit \(typeName) event completed (store: \(storeName))"
                )
                if event.type == .import {
                    self.logCurrentCoreDataContents()
                    self.logShareStatus()
                }
            }
        }
    }
}


extension CloudKitCoreDataController: CloudSharing {
    public func isShared(object: NSManagedObject) -> Bool {
        guard let persistentStore = object.objectID.persistentStore else { return false }
        return persistentStore == sharedPersistentStore
    }

    public func isOwner(object: NSManagedObject) -> Bool {
        guard isShared(object: object) else { return true }
        do {
            guard let share = try container.fetchShares(matching: [object.objectID])[object.objectID] else { return true }
            return share.currentUserParticipant?.permission == .readWrite
        } catch {
            environment?.logger?.logError(message: "isOwner: fetchShares failed", error: error)
            return true
        }
    }

    public func existingShare(for object: NSManagedObject) throws -> CKShare? {
        let shares = try container.fetchShares(matching: [object.objectID])
        return shares[object.objectID]
    }

    public func share(objects: [NSManagedObject], to existingShare: CKShare?) async throws -> CKShare {
        environment?.logger?.logInfo(message: "Creating share for \(objects.count) object(s) (existing share: \(existingShare?.recordID.recordName ?? "none"))")
        do {
            let (_, share, _) = try await container.share(objects, to: existingShare)
            environment?.logger?.logInfo(message: "Share created successfully (recordName: \(share.recordID.recordName), participants: \(share.participants.count))")
            return share
        } catch {
            environment?.logger?.logError(message: "Share creation failed", error: error)
            environment?.crashReporter?.recordNonfatalError(error: error, metadata: ["cloudkit.operation": "share"])
            throw error
        }
    }

    public func acceptShareInvitations(from metadata: [CKShare.Metadata]) async throws {
        guard let sharedStore = sharedPersistentStore else {
            let error = NSError(domain: "io.mcknight.pippin.cloudkit", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Shared persistent store not available"
            ])
            environment?.logger?.logError(message: "acceptShareInvitations: shared store not available", error: error)
            throw error
        }
        environment?.logger?.logInfo(message: "Accepting \(metadata.count) share invitation(s)")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.acceptShareInvitations(from: metadata, into: sharedStore) { [weak self] _, error in
                if let error {
                    self?.environment?.logger?.logError(message: "acceptShareInvitations failed", error: error)
                    self?.environment?.crashReporter?.recordNonfatalError(error: error, metadata: ["cloudkit.operation": "acceptShareInvitations"])
                    continuation.resume(throwing: error)
                } else {
                    self?.environment?.logger?.logInfo(message: "Share invitation(s) accepted successfully")
                    continuation.resume()
                }
            }
        }
    }

    public func fetchAllShares() throws -> [CKShare] {
        var allShares: [CKShare] = []
        let stores = [privatePersistentStore, sharedPersistentStore].compactMap { $0 }
        for store in stores {
            let shares = try container.fetchShares(in: store)
            allShares.append(contentsOf: shares)
        }
        return allShares
    }
}
