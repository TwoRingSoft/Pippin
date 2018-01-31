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
 A `UITableViewCell` subclass providing a label on the left and an image view on the right. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the image view centered on its Y axis.
 */
public class TextAndAccessoryCell: UITableViewCell {

    public var label = UILabel(frame: .zero)
    public var imageAccessoryView = UIImageView(frame: .zero)

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [label, imageAccessoryView].forEach { self.contentView.addSubview($0) }

        label.leadingAnchor == contentView.leadingAnchor + 12
        label.verticalAnchors == contentView.verticalAnchors + 8
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        imageAccessoryView.centerYAnchor == contentView.centerYAnchor
        imageAccessoryView.leadingAnchor == label.trailingAnchor + 20
        imageAccessoryView.widthAnchor == imageAccessoryView.heightAnchor
        imageAccessoryView.verticalAnchors == contentView.verticalAnchors + 8
        imageAccessoryView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageAccessoryView.trailingAnchor == contentView.trailingAnchor - 20
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
