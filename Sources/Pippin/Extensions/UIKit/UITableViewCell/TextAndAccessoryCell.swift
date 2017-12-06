//
//  TextAndAccessoryCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/6/17.
//

import Anchorage
import UIKit

public let textAndAccessoryCellReuseIdentifier = "AddObjectCell"

public class TextAndAccessoryCell: UITableViewCell {

    public var label: UILabel!
    public var imageAccessoryView: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        label = UILabel(frame: .zero)
        imageAccessoryView = UIImageView(frame: .zero)

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
