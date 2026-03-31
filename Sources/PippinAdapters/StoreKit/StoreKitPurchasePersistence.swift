//
//  StoreKitPurchasePersistence.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation

/// Protocol for persisting in-app purchase state. Implement this in your app
/// to provide storage (e.g. Keychain, UserDefaults) for purchase records.
public protocol StoreKitPurchasePersistence {
    func addPurchase(identifier: String, transactionID: String) throws
    func clearPurchases() throws
    func isPurchased(identifier: String) -> Bool
}
