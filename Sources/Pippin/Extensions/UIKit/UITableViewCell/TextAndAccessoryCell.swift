//
//  TextAndAccessoryCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/6/17.
//

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
    fileprivate var trailingImageTrailingWidth: NSLayoutConstraint?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [label, trailingImageAccessory, leadingImageAccessory].forEach { self.contentView.addSubview($0) }
        [trailingImageAccessory, leadingImageAccessory].forEach { $0.contentMode = .scaleAspectFill }
        [leadingImageAccessory, label, trailingImageAccessory].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        leadingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        trailingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        leadingImageLeadingWidth = leadingImageAccessory.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat.horizontalMargin)
        leadingImageAccessoryWidth = leadingImageAccessory.widthAnchor.constraint(equalToConstant: 0)
        trailingImageTrailingWidth = trailingImageAccessory.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: CGFloat.horizontalMargin)
        trailingImageAccessoryWidth = trailingImageAccessory.widthAnchor.constraint(equalToConstant: 0)
        
        [
            leadingImageLeadingWidth,
            leadingImageAccessoryWidth,
            trailingImageAccessoryWidth,
            trailingImageTrailingWidth,
            leadingImageAccessory.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leadingImageAccessory.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            leadingImageAccessory.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
            label.leadingAnchor.constraint(equalTo: leadingImageAccessory.trailingAnchor, constant: CGFloat.horizontalMargin),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            trailingImageAccessory.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trailingImageAccessory.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: CGFloat.horizontalMargin),
            trailingImageAccessory.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            trailingImageAccessory.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
        ].forEach { $0?.isActive = true }
        
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
            spacingConstraint = trailingImageTrailingWidth
            spacingSign = -1
        }

        if let image = image {
            accessory.image = image
            accessory.tintColor = tintColor
            widthConstraint?.constant = .iconSize
            spacingConstraint?.constant = .horizontalMargin * spacingSign
        } else {
            accessory.image = nil
            widthConstraint?.constant = 0
            spacingConstraint?.constant = 0
        }
    }

}
