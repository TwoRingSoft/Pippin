//
//  InAppPurchaseMenuViewController.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

#if canImport(UIKit)

import Anchorage
import Pippin
import SwiftArmcknightUIKit
import UIKit

private let restoreCellReuseIdentifier = "restoreCell"
private let productCellReuseIdentifier = "productCell"

protocol StoreKitMenuDelegate: AnyObject {
    func storeKitMenuSelectedRestorePurchases(menu: InAppPurchaseMenuViewController)
    func storeKitMenu(menu: InAppPurchaseMenuViewController, selectedPurchaseProduct selectedProduct: StoreKitProduct)
}

class InAppPurchaseMenuViewController: UIViewController {

    fileprivate var tableView = UITableView(frame: .zero, style: .plain)
    fileprivate var products: [StoreKitProduct]
    fileprivate weak var delegate: StoreKitMenuDelegate?
    fileprivate var requiredProductIdentifier: String?
    fileprivate var selectedProductIndexPath: IndexPath?
    fileprivate let environment: Environment
    fileprivate let strings: InAppPurchaseFlowStrings
    fileprivate let requiredIndicatorColor: UIColor

    init(products: [StoreKitProduct], requiredProductIdentifier: String?, environment: Environment, strings: InAppPurchaseFlowStrings, requiredIndicatorColor: UIColor, delegate: StoreKitMenuDelegate) {
        self.products = products
        self.delegate = delegate
        self.requiredProductIdentifier = requiredProductIdentifier
        self.environment = environment
        self.strings = strings
        self.requiredIndicatorColor = requiredIndicatorColor
        super.init(nibName: nil, bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(InAppPurchaseCell.self, forCellReuseIdentifier: productCellReuseIdentifier)
        tableView.register(TextAndAccessoryCell.self, forCellReuseIdentifier: restoreCellReuseIdentifier)
        view.addSubview(tableView)
        tableView.edgeAnchors == view.edgeAnchors

        view.backgroundColor = .clear

        title = strings.menuTitle
    }

    func completePurchase() {
        if let requiredID = requiredProductIdentifier, environment.inAppPurchaseVendor?.checkLicense(forInAppPurchase: requiredID) == true {
            self.requiredProductIdentifier = nil
        }

        if let indexPath = selectedProductIndexPath {
            selectedProductIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            // restored purchases
            if let indexPaths = tableView.indexPathsForVisibleRows {
                tableView.reloadRows(at: indexPaths, with: .automatic)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension InAppPurchaseMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
            + 1 // "restore purchases" row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let foregroundColor = environment.colors.foreground
        if isRestorePurchasesRow(indexPath: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: restoreCellReuseIdentifier, for: indexPath)
            let cellText = strings.restorePurchasesTitle
            if let customCell = cell as? TextAndAccessoryCell {
                customCell.label.text = cellText
                customCell.label.textAlignment = .center
                customCell.label.font = environment.fonts.header
                customCell.label.textColor = foregroundColor
                customCell.label.adjustsFontSizeToFitWidth = true
                customCell.label.allowsDefaultTighteningForTruncation = true
                customCell.setAccessoryImage(image: UIImage(systemName: "arrow.down.circle"), location: .trailing, tintColor: foregroundColor)
            }

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = cellText

            cell.addSeparator(backgroundColor: foregroundColor, insets: UIEdgeInsets(horizontal: 3 * CGFloat.horizontalMargin))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: productCellReuseIdentifier, for: indexPath)
            let selectedProduct = product(forIndexPath: indexPath)
            if let iapCell = cell as? InAppPurchaseCell {
                var required = false
                if let requiredID = requiredProductIdentifier {
                    required = requiredID == selectedProduct.product.id
                }
                iapCell.configure(forProduct: selectedProduct, required: required, environment: environment, strings: strings, requiredIndicatorColor: requiredIndicatorColor)
            }

            if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.addSeparator(backgroundColor: foregroundColor, insets: UIEdgeInsets(horizontal: 3 * CGFloat.horizontalMargin))
            }

            return cell
        }
    }

}

extension InAppPurchaseMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isRestorePurchasesRow(indexPath: indexPath) {
            delegate?.storeKitMenuSelectedRestorePurchases(menu: self)
        } else {
            let selectedProduct = product(forIndexPath: indexPath)
            if environment.inAppPurchaseVendor?.checkLicense(forInAppPurchase: selectedProduct.product.id) != true {
                selectedProductIndexPath = indexPath
                delegate?.storeKitMenu(menu: self, selectedPurchaseProduct: selectedProduct)
            }
        }
    }

}

private extension InAppPurchaseMenuViewController {

    func isRestorePurchasesRow(indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    func product(forIndexPath indexPath: IndexPath) -> StoreKitProduct {
        return products[indexPath.row - 1]
    }

}

#endif
