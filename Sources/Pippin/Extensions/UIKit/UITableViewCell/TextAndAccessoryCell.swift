//
//  TextAndAccessoryCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/6/17.
//

import Anchorage
import UIKit

public let textAndAccessoryCellReuseIdentifier = "AddObjectCell"

/**
 A `UITableViewCell` subclass providing a label in the middle and an image view both on the right and left. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the image view centered on its Y axis.
 */
public class TextAndAccessoryCell: UITableViewCell {

    public var label = UILabel(frame: .zero)
    fileprivate var leadingImageAccessory = UIImageView(frame: .zero)
    fileprivate var trailingImageAccessory = UIImageView(frame: .zero)

    fileprivate var leadingImageLeadingWidth: NSLayoutConstraint?
    fileprivate var leadingImageAccessoryWidth: NSLayoutConstraint?
    fileprivate var trailingImageAccessoryWidth: NSLayoutConstraint?
    fileprivate var trailingImageTrailingWIdth: NSLayoutConstraint?

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [label, trailingImageAccessory, leadingImageAccessory].forEach { self.contentView.addSubview($0) }

        [trailingImageAccessory, leadingImageAccessory].forEach { $0.contentMode = .scaleAspectFill }

        leadingImageLeadingWidth = leadingImageAccessory.leadingAnchor == contentView.leadingAnchor + 12
        leadingImageAccessory.centerYAnchor == contentView.centerYAnchor
        leadingImageAccessoryWidth = leadingImageAccessory.widthAnchor == 0
        leadingImageAccessory.verticalAnchors == contentView.verticalAnchors + 8
        leadingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        label.leadingAnchor == leadingImageAccessory.trailingAnchor + 12
        label.verticalAnchors == contentView.verticalAnchors + 8
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        trailingImageAccessory.centerYAnchor == contentView.centerYAnchor
        trailingImageAccessory.leadingAnchor == label.trailingAnchor + 12
        trailingImageAccessoryWidth = trailingImageAccessory.widthAnchor == 0
        trailingImageAccessory.verticalAnchors == contentView.verticalAnchors + 8
        trailingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        trailingImageTrailingWIdth = trailingImageAccessory.trailingAnchor == contentView.trailingAnchor - 12

        [leadingImageAccessoryWidth, trailingImageAccessoryWidth].forEach { $0?.priority = .required }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public enum AccessorySide {
        case leading
        case trailing
    }

    public func setAccessoryImage(image: UIImage?, side: AccessorySide, tintColor: UIColor) {
        let accessory: UIImageView
        let widthConstraint: NSLayoutConstraint?
        let spacingConstraint: NSLayoutConstraint?
        let spacingSign: CGFloat

        switch side {
        case .leading:
            accessory = leadingImageAccessory
            widthConstraint = leadingImageAccessoryWidth
            spacingConstraint = leadingImageLeadingWidth
            spacingSign = 1
        case .trailing:
            accessory = trailingImageAccessory
            widthConstraint = trailingImageAccessoryWidth
            spacingConstraint = trailingImageTrailingWIdth
            spacingSign = -1
        }

        if let image = image {
            accessory.image = image
            accessory.tintColor = tintColor
            widthConstraint?.constant = 35
            spacingConstraint?.constant = 12 * spacingSign
        } else {
            accessory.image = nil
            widthConstraint?.constant = 0
            spacingConstraint?.constant = 0
        }
    }

}
