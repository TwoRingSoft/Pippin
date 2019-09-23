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
    fileprivate var topImageAccessory = UIImageView(frame: .zero)
    fileprivate var bottomImageAccessory = UIImageView(frame: .zero)

    fileprivate var leadingImageLeadingWidth: NSLayoutConstraint?
    fileprivate var leadingImageAccessoryWidth: NSLayoutConstraint?
    fileprivate var trailingImageAccessoryWidth: NSLayoutConstraint?
    fileprivate var trailingImageTrailingWidth: NSLayoutConstraint?
    fileprivate var topImageLeadingHeight: NSLayoutConstraint?
    fileprivate var topImageAccessoryHeight: NSLayoutConstraint?
    fileprivate var bottomImageAccessoryHeight: NSLayoutConstraint?
    fileprivate var bottomImageTrailingHeight: NSLayoutConstraint?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [label, trailingImageAccessory, leadingImageAccessory, topImageAccessory, bottomImageAccessory].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [trailingImageAccessory, leadingImageAccessory, topImageAccessory, bottomImageAccessory].forEach { $0.contentMode = .scaleAspectFill }
        
        leadingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        trailingImageAccessory.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        leadingImageLeadingWidth = leadingImageAccessory.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0)
        leadingImageAccessoryWidth = leadingImageAccessory.widthAnchor.constraint(equalToConstant: 0)
        trailingImageTrailingWidth = trailingImageAccessory.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0)
        trailingImageAccessoryWidth = trailingImageAccessory.widthAnchor.constraint(equalToConstant: 0)
        topImageLeadingHeight = topImageAccessory.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 0)
        topImageAccessoryHeight = topImageAccessory.heightAnchor.constraint(equalToConstant: 0)
        bottomImageTrailingHeight = bottomImageAccessory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: 0)
        bottomImageAccessoryHeight = bottomImageAccessory.heightAnchor.constraint(equalToConstant: 0)
        
        [
            leadingImageLeadingWidth,
            leadingImageAccessoryWidth,
            trailingImageAccessoryWidth,
            trailingImageTrailingWidth,
            topImageLeadingHeight,
            topImageAccessoryHeight,
            bottomImageAccessoryHeight,
            bottomImageTrailingHeight,
            leadingImageAccessory.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            leadingImageAccessory.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: CGFloat.verticalMargin),
            leadingImageAccessory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -CGFloat.verticalMargin),
            topImageAccessory.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: leadingImageAccessory.trailingAnchor, constant: CGFloat.horizontalMargin),
            label.topAnchor.constraint(equalTo: topImageAccessory.bottomAnchor, constant: CGFloat.verticalMargin),
            label.bottomAnchor.constraint(equalTo: bottomImageAccessory.topAnchor, constant: -CGFloat.verticalMargin),
            trailingImageAccessory.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            trailingImageAccessory.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: CGFloat.horizontalMargin),
            trailingImageAccessory.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: CGFloat.verticalMargin),
            trailingImageAccessory.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -CGFloat.verticalMargin),
            bottomImageAccessory.centerXAnchor.constraint(equalTo: label.centerXAnchor),
        ].forEach { $0?.isActive = true }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public enum AccessoryLocation {
        case leading
        case trailing
        case top
        case bottom
    }

    public func setAccessoryImage(image: UIImage?, location: AccessoryLocation, tintColor: UIColor) {
        let accessory: UIImageView
        let sizeConstraint: NSLayoutConstraint?
        let spacingConstraint: NSLayoutConstraint?
        let spacingSign: CGFloat

        switch location {
        case .leading:
            accessory = leadingImageAccessory
            sizeConstraint = leadingImageAccessoryWidth
            spacingConstraint = leadingImageLeadingWidth
            spacingSign = 1
        case .trailing:
            accessory = trailingImageAccessory
            sizeConstraint = trailingImageAccessoryWidth
            spacingConstraint = trailingImageTrailingWidth
            spacingSign = -1
        case .top:
            accessory = topImageAccessory
            sizeConstraint = topImageAccessoryHeight
            spacingConstraint = topImageLeadingHeight
            spacingSign = 1
        case .bottom:
            accessory = bottomImageAccessory
            sizeConstraint = bottomImageAccessoryHeight
            spacingConstraint = bottomImageTrailingHeight
            spacingSign = -1
        }

        if let image = image {
            accessory.image = image
            accessory.tintColor = tintColor
            sizeConstraint?.constant = .iconSize
            spacingConstraint?.constant = .horizontalMargin * spacingSign
        } else {
            accessory.image = nil
            sizeConstraint?.constant = 0
            spacingConstraint?.constant = 0
        }
    }

}
