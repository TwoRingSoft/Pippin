//
//  TextCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

public let textCellReuseIdentifier = "TextCell"

public class TextCell: UITableViewCell {

    public var label = UILabel(frame: .zero)
    private var indicator = UIImageView()
    private var indicatorWidthConstraint: NSLayoutConstraint?
    private var separator = UIView(frame: .zero)
    private var separatorHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        indicator.tintColor = .white
        indicator.contentMode = .scaleAspectFit
        
        separator.backgroundColor = .white

        [label, indicator, separator].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        indicatorWidthConstraint = indicator.widthAnchor.constraint(equalToConstant: 0)
        separatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: 0)
        [
            indicatorWidthConstraint,
            separatorHeightConstraint,
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat.horizontalMargin),
            indicator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: CGFloat.horizontalSpacing),
            indicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CGFloat.horizontalSpacing),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3 * CGFloat.horizontalMargin),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3 * CGFloat.horizontalMargin),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ].forEach { $0?.isActive = true }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showIndicator(image: UIImage?, highlightedImage: UIImage?) {
        indicator.image = image
        indicator.highlightedImage = highlightedImage
        indicatorWidthConstraint?.constant = .iconSize
    }

    public func setDimmed(dimmed: Bool) {
        label.isEnabled = dimmed
        indicator.alpha = dimmed ? 1 : 0.5
    }

    public func showSeparator(visible: Bool) {
        separatorHeightConstraint?.constant = visible ? UIScreen.main.hairlineWidth : 0
    }

}
