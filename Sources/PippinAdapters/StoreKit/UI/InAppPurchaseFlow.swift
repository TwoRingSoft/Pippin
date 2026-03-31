//
//  InAppPurchaseFlow.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

#if canImport(UIKit)

import Pippin
import SwiftArmcknight
import SwiftArmcknightUIKit
import UIKit

/// Displays the IAP menu and performs the appropriate actions for user
/// selections, using the Pippin protocol for IAP vendors.
public class InAppPurchaseFlow: NSObject {

    fileprivate weak var delegate: InAppPurchaseFlowDelegate?
    fileprivate var requiredProductIdentifier: String?
    fileprivate var requiredProductObject: StoreKitProduct?
    fileprivate var window = UIWindow(frame: UIScreen.main.bounds)
    fileprivate var automaticallyDismiss: Bool
    fileprivate let environment: Environment
    fileprivate let strings: InAppPurchaseFlowStrings
    fileprivate let blurStyle: UIBlurEffect.Style
    fileprivate let requiredIndicatorColor: UIColor

    public init(
        environment: Environment,
        strings: InAppPurchaseFlowStrings = InAppPurchaseFlowStrings(),
        blurStyle: UIBlurEffect.Style = .dark,
        automaticallyDismiss: Bool = true,
        requiredProductIdentifier: String? = nil,
        requiredIndicatorColor: UIColor = .green,
        delegate: InAppPurchaseFlowDelegate? = nil
    ) {
        self.environment = environment
        self.strings = strings
        self.blurStyle = blurStyle
        self.automaticallyDismiss = automaticallyDismiss
        self.requiredProductIdentifier = requiredProductIdentifier
        self.requiredIndicatorColor = requiredIndicatorColor
        self.delegate = delegate
        super.init()
    }

    public func start() {
        environment.activityIndicator?.show(withAttributedText: NSAttributedString(string: strings.fetchActivityIndicatorLabel, attributes: [NSAttributedString.Key.font: environment.fonts.bold]), completion: nil)

        environment.inAppPurchaseVendor?.fetchProducts { (products: [StoreKitProduct], error) -> (Void) in
            self.environment.activityIndicator?.hide(completion: nil)
            if let error = error {
                self.environment.logger?.logError(message: String(format: "[%@] Failed to fetch products: %@", instanceType(self), String(describing: error)), error: error)
                self.environment.alerter?.showAlert(title: self.strings.fetchErrorTitle, message: self.strings.fetchErrorMessage, type: .error, dismissal: .interactive, occlusion: .strong)
                return
            }

            self.requiredProductObject = products.filter({ (product) -> Bool in
                product.product.id == self.requiredProductIdentifier
            }).first

            let rootVC = UIViewController(nibName: nil, bundle: nil)
            self.window.rootViewController = rootVC
            self.window.windowLevel = UIWindow.Level.normal
            self.window.isHidden = false

            let menu = InAppPurchaseMenuViewController(products: products, requiredProductIdentifier: self.requiredProductIdentifier, environment: self.environment, strings: self.strings, requiredIndicatorColor: self.requiredIndicatorColor, delegate: self)
            let dismissable = DismissableModalViewController(childViewController: menu, titleFont: self.environment.fonts.title, backgroundColor: .clear, imageBundle: self.environment.sharedAssetsBundle, onClose: {
                rootVC.dismiss(animated: true)
            })
            let blurred = BlurViewController(viewController: dismissable, blurStyle: self.blurStyle)
            rootVC.present(blurred, animated: true, completion: nil)
        }
    }

}

// MARK: StoreKitMenuDelegate
extension InAppPurchaseFlow: StoreKitMenuDelegate {

    func storeKitMenuSelectedRestorePurchases(menu: InAppPurchaseMenuViewController) {
        environment.activityIndicator?.show(withAttributedText: NSAttributedString(string: strings.restoreActivityIndicatorLabel, attributes: [NSAttributedString.Key.font: environment.fonts.bold]), completion: nil)
        environment.inAppPurchaseVendor?.restorePurchases(completion: { (productIDs: [String], error) -> (Void) in
            self.environment.activityIndicator?.hide(completion: nil)
            if let error = error {
                self.environment.logger?.logError(message: String(format: "[%@] restore purchases failed: %@", instanceType(self), String(describing: error)), error: error)
                self.environment.alerter?.showAlert(title: self.strings.genericErrorTitle, message: self.strings.restoreFailedMessage, type: .error, dismissal: .interactive, occlusion: .strong)
                return
            }

            if productIDs.isEmpty {
                self.environment.alerter?.showAlert(title: self.strings.restorePurchasesTitle, message: self.strings.restoreNoneRestoredMessage, type: .warning, dismissal: .interactive, occlusion: .strong)
            } else {
                self.environment.alerter?.showAlert(title: self.strings.thanksTitle, message: String(format: self.strings.restoreSuccessFormat, productIDs.count, productIDs.count == 1 ? "" : "s"), type: .success, dismissal: .interactive, occlusion: .strong)
                menu.completePurchase()
                if let requiredID = self.requiredProductIdentifier, productIDs.contains(requiredID) {
                    self.dismissMenu() {
                        self.delegate?.inAppPurchaseFlowDidRestore(self, productIDs: productIDs)
                    }
                }
            }
        })
    }

    func storeKitMenu(menu: InAppPurchaseMenuViewController, selectedPurchaseProduct selectedProduct: StoreKitProduct) {
        let performPurchase = {
            self.environment.activityIndicator?.show(withAttributedText: NSAttributedString(string: String(format: self.strings.purchasingProductFormat, selectedProduct.product.displayName), attributes: [NSAttributedString.Key.font: self.environment.fonts.bold]), completion: nil)
            self.environment.inAppPurchaseVendor?.purchase(product: selectedProduct, completion: { (error) -> (Void) in
                self.environment.activityIndicator?.hide(completion: nil)
                if let error = error {
                    self.environment.logger?.logError(message: String(format: "[%@] Failed to purchase product: %@.", instanceType(self), String(describing: error)), error: error)
                    self.environment.alerter?.showAlert(title: self.strings.purchaseErrorTitle, message: self.strings.purchaseErrorMessage, type: .error, dismissal: .interactive, occlusion: .strong)
                    return
                }

                self.environment.alerter?.showAlert(title: self.strings.thanksTitle, message: String(format: self.strings.purchaseCompleteFormat, selectedProduct.product.displayName), type: .success, dismissal: .interactive, occlusion: .strong)
                menu.completePurchase()

                let callback: EmptyBlock = {
                    self.delegate?.inAppPurchaseFlowDidPurchase(self, product: selectedProduct)
                }

                if self.automaticallyDismiss {
                    self.dismissMenu(completion: callback)
                } else {
                    callback()
                }
            })
        }

        guard let requiredProductObject = requiredProductObject else {
            performPurchase()
            return
        }

        if let requiredID = self.requiredProductIdentifier {
            guard selectedProduct.product.id == requiredID else {
                environment.logger?.logInfo(message: String(format: "[%@] Entered IAP menu because user needs to unlock %@ but selected %@.", instanceType(self), requiredID, selectedProduct.product.id))
                environment.alerter?.showConfirmationAlert(title: strings.confirmationTitle, message: String(format: strings.purchaseMismatchFormat, requiredProductObject.product.displayName, selectedProduct.product.displayName), type: .warning, confirmButtonTitle: strings.confirmationButtonTitle, confirmationCompletion: {
                    self.environment.alerter?.hide()
                    performPurchase()
                })
                return
            }

            performPurchase()
        }
    }

}

// MARK: Private
fileprivate extension InAppPurchaseFlow {
    func dismissMenu(completion: @escaping EmptyBlock) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.window.rootViewController?.dismiss(animated: true, completion: completion)
        })
    }
}

#endif
