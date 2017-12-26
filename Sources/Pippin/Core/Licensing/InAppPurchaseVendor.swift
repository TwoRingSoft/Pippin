//
//  InAppPurchaseVendor.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/26/17.
//

import Foundation

public typealias IAPPurchaseCheckCompletion = ((_ purchased: Bool) -> (Void))

public protocol InAppPurchaseVendor {

    func checkLicense(forInAppPurchase identifier: String, completion: @escaping IAPPurchaseCheckCompletion)

}
