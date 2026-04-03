import CoreData
import CloudKit

public protocol CloudSharing: AnyObject, EnvironmentallyConscious {
    func isShared(object: NSManagedObject) -> Bool
    func isOwner(object: NSManagedObject) -> Bool
    func existingShare(for object: NSManagedObject) throws -> CKShare?
    func share(objects: [NSManagedObject], to existingShare: CKShare?) async throws -> CKShare
    func acceptShareInvitations(from metadata: [CKShare.Metadata]) async throws
    func fetchAllShares() throws -> [CKShare]
}
