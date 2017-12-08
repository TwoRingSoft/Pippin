//
//  TextViewCell.swift
//  Pods
//
//  Created by Andrew McKnight on 12/7/17.
//

import Anchorage
import UIKit

public let textViewCellReuseIdentifier = "TextViewCell"

/**
 A `UITableViewCell` subclass providing a label on the left and a text view on the right. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the text view at the top.
 */
public class TextViewCell: UITableViewCell {

    public let textView = UITextView(frame: .zero)
    public let titleLabel = UILabel(frame: .zero)

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)

        titleLabel.leadingAnchor == contentView.leadingAnchor + 12
        titleLabel.topAnchor == contentView.topAnchor + 8
        titleLabel.bottomAnchor >= contentView.bottomAnchor - 8

        textView.leadingAnchor == titleLabel.trailingAnchor + 12
        textView.topAnchor == titleLabel.topAnchor
        textView.trailingAnchor == contentView.trailingAnchor - 12
        textView.bottomAnchor >= contentView.bottomAnchor - 8
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
