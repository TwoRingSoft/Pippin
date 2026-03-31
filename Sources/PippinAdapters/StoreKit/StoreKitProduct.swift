//
//  StoreKitProduct.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

import Pippin
import StoreKit

/// A concrete `InAppPurchase` type wrapping a StoreKit 2 `Product`.
public struct StoreKitProduct: InAppPurchase {
    public typealias Product = StoreKit.Product
    public var product: StoreKit.Product

    public init(product: StoreKit.Product) {
        self.product = product
    }
}
