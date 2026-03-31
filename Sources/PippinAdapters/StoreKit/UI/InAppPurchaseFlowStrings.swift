//
//  InAppPurchaseFlowStrings.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

import Foundation

/// All localized strings the IAP UI needs. Each has a sensible English default
/// so the adapter works out of the box. Apps can override any string via the
/// memberwise init.
public struct InAppPurchaseFlowStrings {
    public var fetchActivityIndicatorLabel: String
    public var restoreActivityIndicatorLabel: String
    public var purchasingProductFormat: String
    public var menuTitle: String
    public var restorePurchasesTitle: String
    public var fetchErrorTitle: String
    public var fetchErrorMessage: String
    public var purchaseErrorTitle: String
    public var purchaseErrorMessage: String
    public var restoreFailedMessage: String
    public var genericErrorTitle: String
    public var thanksTitle: String
    public var purchaseCompleteFormat: String
    public var restoreSuccessFormat: String
    public var restoreNoneRestoredMessage: String
    public var confirmationTitle: String
    public var confirmationButtonTitle: String
    public var purchaseMismatchFormat: String
    public var purchasedPriceMessage: String

    public init(
        fetchActivityIndicatorLabel: String = "Fetching In App Purchase information...",
        restoreActivityIndicatorLabel: String = "Restoring purchases...",
        purchasingProductFormat: String = "Purchasing '%@'...",
        menuTitle: String = "Premium Features",
        restorePurchasesTitle: String = "Restore purchases",
        fetchErrorTitle: String = "Error connecting to iTunes",
        fetchErrorMessage: String = "Please make sure your device has a network connection and that you are signed into iCloud.",
        purchaseErrorTitle: String = "Failed to complete purchase",
        purchaseErrorMessage: String = "Please try again later.",
        restoreFailedMessage: String = "Cannot restore purchases at this time. Please try again later.",
        genericErrorTitle: String = "Error",
        thanksTitle: String = "Thank You!",
        purchaseCompleteFormat: String = "You purchased '%@'. Hope you enjoy!",
        restoreSuccessFormat: String = "Successfully restored %i purchase%@.",
        restoreNoneRestoredMessage: String = "The request completed successfully, but no purchases were restored.",
        confirmationTitle: String = "Are you sure?",
        confirmationButtonTitle: String = "OK",
        purchaseMismatchFormat: String = "You need to purchase '%@' but you selected '%@'. Tap 'OK' to confirm.",
        purchasedPriceMessage: String = "Purchased"
    ) {
        self.fetchActivityIndicatorLabel = fetchActivityIndicatorLabel
        self.restoreActivityIndicatorLabel = restoreActivityIndicatorLabel
        self.purchasingProductFormat = purchasingProductFormat
        self.menuTitle = menuTitle
        self.restorePurchasesTitle = restorePurchasesTitle
        self.fetchErrorTitle = fetchErrorTitle
        self.fetchErrorMessage = fetchErrorMessage
        self.purchaseErrorTitle = purchaseErrorTitle
        self.purchaseErrorMessage = purchaseErrorMessage
        self.restoreFailedMessage = restoreFailedMessage
        self.genericErrorTitle = genericErrorTitle
        self.thanksTitle = thanksTitle
        self.purchaseCompleteFormat = purchaseCompleteFormat
        self.restoreSuccessFormat = restoreSuccessFormat
        self.restoreNoneRestoredMessage = restoreNoneRestoredMessage
        self.confirmationTitle = confirmationTitle
        self.confirmationButtonTitle = confirmationButtonTitle
        self.purchaseMismatchFormat = purchaseMismatchFormat
        self.purchasedPriceMessage = purchasedPriceMessage
    }
}
