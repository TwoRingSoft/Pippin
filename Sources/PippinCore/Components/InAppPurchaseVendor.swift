//
//  InAppPurchaseVendor.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

public typealias IAPProductsCompletion<T> = ((_ products: [T], _ error: Error?) -> (Void)) where T: InAppPurchase
public typealias IAPRestoredProductsCompletion = ((_ productIDs: [String], _ error: Error?) -> (Void))
public typealias IAPPurchaseCompletion = ((_ error: Error?) -> (Void))

public protocol InAppPurchase {
    associatedtype Product
    var product: Product { get set }
}

public protocol InAppPurchaseVendor: EnvironmentallyConscious {

    func fetchProducts<T>(completion: @escaping IAPProductsCompletion<T>) where T: InAppPurchase
    func checkLicense(forInAppPurchase identifier: String) -> Bool
    func purchase<T>(product: T, completion: @escaping IAPPurchaseCompletion) where T: InAppPurchase
    func restorePurchases(completion: @escaping IAPRestoredProductsCompletion)

}
