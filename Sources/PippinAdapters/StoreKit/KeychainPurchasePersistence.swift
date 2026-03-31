//
//  KeychainPurchasePersistence.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation
import Security

/// Default `StoreKitPurchasePersistence` implementation backed by the iOS Keychain.
/// The app provides the account name and storage key at init.
public final class KeychainPurchasePersistence: StoreKitPurchasePersistence {

    private typealias ProductIdentifier = String
    private typealias TransactionIdentifier = String
    private typealias ProductToTransactionIDMap = [ProductIdentifier: TransactionIdentifier]

    private let account: String
    private let storageKey: String

    public init(account: String, storageKey: String) {
        self.account = account
        self.storageKey = storageKey
    }

    public func addPurchase(identifier: String, transactionID: String) throws {
        var purchasedProductIDs: ProductToTransactionIDMap = KeychainPurchasePersistence.loadData(forAccount: account)?[storageKey] as? ProductToTransactionIDMap ?? ProductToTransactionIDMap()
        purchasedProductIDs[identifier] = transactionID
        try KeychainPurchasePersistence.updateData(data: [storageKey: purchasedProductIDs], forAccount: account)
    }

    public func clearPurchases() throws {
        try KeychainPurchasePersistence.updateData(data: [storageKey: ProductToTransactionIDMap()], forAccount: account)
    }

    public func isPurchased(identifier: String) -> Bool {
        let loaded = KeychainPurchasePersistence.loadData(forAccount: account)
        let purchases = loaded?[storageKey] as? ProductToTransactionIDMap ?? ProductToTransactionIDMap()
        return purchases.keys.contains(identifier)
    }

}

// MARK: Private keychain helpers
private extension KeychainPurchasePersistence {

    static func loadData(forAccount account: String) -> [String: Any]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any]
    }

    static func updateData(data: [String: Any], forAccount account: String) throws {
        let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)

        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]

        let existingStatus = SecItemCopyMatching(searchQuery as CFDictionary, nil)

        if existingStatus == errSecSuccess {
            let updateQuery: [String: Any] = [
                kSecValueData as String: archivedData,
            ]
            let status = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
            if status != errSecSuccess {
                throw NSError(domain: "com.pippin.storekit.keychain", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to update keychain item"])
            }
        } else {
            var addQuery = searchQuery
            addQuery[kSecValueData as String] = archivedData
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            if status != errSecSuccess {
                throw NSError(domain: "com.pippin.storekit.keychain", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to add keychain item"])
            }
        }
    }

}
