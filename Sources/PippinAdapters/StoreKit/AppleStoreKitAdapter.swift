//
//  AppleStoreKitAdapter.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation
import Pippin
import StoreKit
import SwiftArmcknight

/// A StoreKit 2 implementation of `InAppPurchaseVendor`. Parameterized by
/// product identifiers and a persistence layer provided by the consuming app.
public final class AppleStoreKitAdapter: NSObject, EnvironmentallyConscious {

    public var environment: Environment?

    private let productIDs: Set<String>
    private let persistence: StoreKitPurchasePersistence
    private var transactionListener: Task<Void, Error>?

    public init(productIDs: Set<String>, persistence: StoreKitPurchasePersistence, environment: Environment?) {
        self.productIDs = productIDs
        self.persistence = persistence
        self.environment = environment
        super.init()

        transactionListener = listenForTransactions()

        #if DEBUG
            if ProcessInfo.launchedWith(launchArgument: LaunchArgument.wipePersistedInAppPurchases) {
                wipeIAPs()
            }

            guard !ProcessInfo.launchedWith(launchArgument: LaunchArgument.unlockIAP) else {
                return
            }
        #endif

        Task {
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Clears all persisted purchase data.
    public func wipeIAPs() {
        do {
            environment?.logger?.logInfo(message: String(format: "[%@] Wiping persisted IAP data.", instanceType(self)))
            try persistence.clearPurchases()
        } catch {
            environment?.logger?.logWarning(message: String(format: "[%@] Failed to wipe persisted IAP data: %@", instanceType(self), String(describing: error)))
        }
    }

}

// MARK: InAppPurchaseVendor
extension AppleStoreKitAdapter: InAppPurchaseVendor {

    public func fetchProducts<T>(completion: @escaping IAPProductsCompletion<T>) where T: InAppPurchase {
        guard let typedCompletion = completion as? (([StoreKitProduct], Error?) -> (Void)) else {
            fatalError("AppleStoreKitAdapter requires StoreKitProduct as the InAppPurchase type.")
        }

        let performProductFetch = {
            Task {
                do {
                    let storeProducts = try await Product.products(for: self.productIDs)
                    let products = storeProducts.map { StoreKitProduct(product: $0) }
                    await MainActor.run {
                        typedCompletion(products, nil)
                    }
                } catch {
                    await MainActor.run {
                        typedCompletion([], error)
                    }
                }
            }
        }

        #if DEBUG
            if ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateProductFetch) {
                // StoreKit 2 uses StoreKit Testing in Xcode for simulation;
                // fall through to the real fetch which uses the test configuration.
                performProductFetch()
            } else {
                performProductFetch()
            }
        #else
            performProductFetch()
        #endif
    }

    public func checkLicense(forInAppPurchase identifier: String) -> Bool {
        #if DEBUG
            if ProcessInfo.launchedWith(launchArgument: LaunchArgument.unlockIAP) {
                environment?.logger?.logInfo(message: String(format: "[%@] IAPs unlocked: all products return as purchased.", instanceType(self)))
                return true
            }

            if let simulatedPersistedPurchases = EnvironmentVariable.simulatedPurchasedInAppPurchaseIdentifiers.value(),
               simulatedPersistedPurchases.components(separatedBy: EnvironmentVariable.simulatedInAppPurchaseIdentifierSeparator).contains(identifier) {
                environment?.logger?.logInfo(message: String(format: "[%@] simulating persisted purchased product with id: %@", instanceType(self), identifier))
                return true
            }
        #endif

        return persistence.isPurchased(identifier: identifier)
    }

    public func purchase<T>(product: T, completion: @escaping IAPPurchaseCompletion) where T: InAppPurchase {
        guard let p = product as? StoreKitProduct else {
            fatalError("AppleStoreKitAdapter requires StoreKitProduct as the InAppPurchase type.")
        }

        let performPurchase = {
            Task {
                do {
                    let result = try await p.product.purchase()
                    switch result {
                    case .success(let verification):
                        let transaction = try self.checkVerified(verification)
                        try self.persistence.addPurchase(identifier: p.product.id, transactionID: String(transaction.id))
                        await transaction.finish()
                        await MainActor.run { completion(nil) }
                    case .userCancelled:
                        await MainActor.run {
                            completion(NSError(domain: "com.pippin.storekit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"]))
                        }
                    case .pending:
                        self.environment?.logger?.logInfo(message: String(format: "[%@] Purchase pending approval.", valueType(self)))
                        await MainActor.run { completion(nil) }
                    @unknown default:
                        await MainActor.run { completion(nil) }
                    }
                } catch {
                    await MainActor.run { completion(error) }
                }
            }
        }

        #if DEBUG
            precondition(!(ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateProductPurchaseSuccess) && ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateProductPurchaseFailure)))
            if ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateProductPurchaseSuccess) {
                environment?.logger?.logInfo(message: String(format: "[%@] simulating successful purchase for product id: %@", instanceType(self), p.product.id))
                do {
                    try persistence.addPurchase(identifier: p.product.id, transactionID: "test identifier")
                } catch {
                    environment?.logger?.logWarning(message: String(format: "[%@] Failed to persist test in app purchase: %@", instanceType(self), String(describing: error)))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { completion(nil) }
            } else if ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateProductPurchaseFailure) {
                environment?.logger?.logInfo(message: String(format: "[%@] simulating purchase failure for product id: %@", instanceType(self), p.product.id))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    completion(NSError(domain: String(asRDNSForCurrentAppWithSubpaths: ["test-error", "in-app-purchases"]), code: 0, userInfo: nil))
                }
            } else {
                performPurchase()
            }
        #else
            performPurchase()
        #endif
    }

    public func restorePurchases(completion: @escaping IAPRestoredProductsCompletion) {
        let performRestore = {
            Task {
                do {
                    try await AppStore.sync()
                    var restoredIDs = [String]()
                    for await result in Transaction.currentEntitlements {
                        if let transaction = try? self.checkVerified(result) {
                            try? self.persistence.addPurchase(identifier: transaction.productID, transactionID: String(transaction.id))
                            restoredIDs.append(transaction.productID)
                        }
                    }
                    await MainActor.run { completion(restoredIDs, nil) }
                } catch {
                    await MainActor.run { completion([], error) }
                }
            }
        }

        #if DEBUG
            precondition(!(ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateInAppPurchaseRestoreSuccess) && ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateInAppPurchaseRestoreFailure)))
            if ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateInAppPurchaseRestoreSuccess) {
                let restoredIDs = EnvironmentVariable.simulatedRestoredInAppPurchaseIdentifiers.value()?.components(separatedBy: EnvironmentVariable.simulatedInAppPurchaseIdentifierSeparator) ?? []
                restoredIDs.forEach {
                    do {
                        try persistence.addPurchase(identifier: $0, transactionID: "test identifier")
                    } catch {
                        environment?.logger?.logWarning(message: String(format: "[%@] Failed to persist test in app purchase: %@", instanceType(self), String(describing: error)))
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { completion(restoredIDs, nil) }
            } else if ProcessInfo.launchedWith(launchArgument: LaunchArgument.simulateInAppPurchaseRestoreFailure) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    completion([], NSError(domain: String(asRDNSForCurrentAppWithSubpaths: ["test-error", "in-app-purchases", "restore purchases"]), code: 1, userInfo: nil))
                }
            } else {
                performRestore()
            }
        #else
            performRestore()
        #endif
    }

}

// MARK: Private
private extension AppleStoreKitAdapter {

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    try self.persistence.addPurchase(identifier: transaction.productID, transactionID: String(transaction.id))
                    await transaction.finish()
                } catch {
                    self.environment?.logger?.logWarning(message: String(format: "[%@] Transaction listener error: %@", valueType(self), String(describing: error)))
                }
            }
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                try persistence.addPurchase(identifier: transaction.productID, transactionID: String(transaction.id))
            } catch {
                environment?.logger?.logWarning(message: String(format: "[%@] Failed to refresh entitlement: %@", valueType(self), String(describing: error)))
            }
        }
    }

}
