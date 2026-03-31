//
//  InAppPurchaseFlowDelegate.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

#if canImport(UIKit)

import Foundation

public protocol InAppPurchaseFlowDelegate: AnyObject {
    func inAppPurchaseFlowDidPurchase(_ flow: InAppPurchaseFlow, product: StoreKitProduct)
    func inAppPurchaseFlowDidRestore(_ flow: InAppPurchaseFlow, productIDs: [String])
}

#endif
