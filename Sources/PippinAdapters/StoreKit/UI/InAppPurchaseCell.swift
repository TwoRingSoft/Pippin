//
//  InAppPurchaseCell.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 3/30/26.
//

#if canImport(UIKit)

import Anchorage
import Pippin
import SwiftArmcknightUIKit
import UIKit

class InAppPurchaseCell: UITableViewCell {

    fileprivate let priceLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    fileprivate let descriptionLabel = UILabel()

    fileprivate let requiredIndicator = UIImageView()
    fileprivate var requiredIndicatorWidth: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        descriptionLabel.numberOfLines = 0

        [priceLabel, titleLabel, descriptionLabel].forEach { contentView.addSubview($0) }
        contentView.addSubview(requiredIndicator)

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        requiredIndicator.trailingAnchor == contentView.trailingAnchor - CGFloat.horizontalMargin
        requiredIndicator.centerYAnchor == contentView.centerYAnchor
        requiredIndicatorWidth = requiredIndicator.widthAnchor == 0

        priceLabel.topAnchor == contentView.topAnchor + CGFloat.verticalMargin
        priceLabel.leadingAnchor == contentView.leadingAnchor + CGFloat.horizontalMargin
        titleLabel.firstBaselineAnchor == priceLabel.firstBaselineAnchor
        titleLabel.leadingAnchor == priceLabel.trailingAnchor + CGFloat.horizontalSpacing
        titleLabel.trailingAnchor == requiredIndicator.leadingAnchor - CGFloat.horizontalSpacing

        descriptionLabel.topAnchor == titleLabel.bottomAnchor + CGFloat.verticalMargin
        descriptionLabel.leadingAnchor == priceLabel.leadingAnchor
        descriptionLabel.trailingAnchor == titleLabel.trailingAnchor
        descriptionLabel.bottomAnchor == contentView.bottomAnchor - CGFloat.verticalMargin

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        isAccessibilityElement = true
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Internal
extension InAppPurchaseCell {

    func configure(forProduct product: StoreKitProduct, required: Bool, environment: Environment, strings: InAppPurchaseFlowStrings, requiredIndicatorColor: UIColor) {
        let fonts = environment.fonts
        let colors = environment.colors

        priceLabel.font = fonts.text
        titleLabel.font = fonts.bold
        descriptionLabel.font = fonts.italic

        let foreground = colors.foreground
        priceLabel.textColor = foreground
        titleLabel.textColor = foreground
        titleLabel.textAlignment = .right
        descriptionLabel.textColor = foreground
        descriptionLabel.textAlignment = .right

        requiredIndicator.image = UIImage(systemName: "exclamationmark.triangle.fill")
        requiredIndicator.tintColor = requiredIndicatorColor

        let purchased = environment.inAppPurchaseVendor?.checkLicense(forInAppPurchase: product.product.id) ?? false

        let price: String
        if purchased {
            price = strings.purchasedPriceMessage
            [titleLabel, descriptionLabel, priceLabel].forEach {
                $0.textColor = UIColor.lightGray
            }
        } else {
            price = product.product.displayPrice
        }
        self.priceLabel.text = price

        titleLabel.text = product.product.displayName
        descriptionLabel.text = product.product.description

        accessibilityLabel = product.product.displayName

        requiredIndicatorWidth?.constant = required ? .iconSize : 0
    }

}

#endif
