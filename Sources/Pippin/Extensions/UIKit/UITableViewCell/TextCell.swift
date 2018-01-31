//
//  TextCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

public let textCellReuseIdentifier = "TextCell"

public class TextCell: UITableViewCell {

    public var label: UILabel!
    private var indicator: UIImageView!
    private var indicatorWidthConstraint: NSLayoutConstraint!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        label = UILabel(frame: .zero)

        indicator = UIImageView()
        indicator.tintColor = .white
        indicator.contentMode = .scaleAspectFit

        [ label, indicator ].forEach {
            contentView.addSubview($0)
        }

        label.verticalAnchors == contentView.verticalAnchors + 8
        label.leadingAnchor == contentView.leadingAnchor + 12
        indicator.leadingAnchor == label.trailingAnchor + 12
        indicator.trailingAnchor == contentView.trailingAnchor - 12
        indicator.centerYAnchor == contentView.centerYAnchor
        indicatorWidthConstraint = indicator.widthAnchor == 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showIndicator(image: UIImage?, highlightedImage: UIImage?) {
        indicator.image = image
        indicator.highlightedImage = highlightedImage
        indicatorWidthConstraint.constant = 35
    }

}
