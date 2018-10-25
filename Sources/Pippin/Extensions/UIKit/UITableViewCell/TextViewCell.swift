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

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        
        titleLabel.leadingAnchor == contentView.leadingAnchor + CGFloat.horizontalMargin
        titleLabel.topAnchor == contentView.topAnchor + CGFloat.verticalMargin
        titleLabel.bottomAnchor <= contentView.bottomAnchor - CGFloat.verticalMargin

        textView.leadingAnchor == titleLabel.trailingAnchor + CGFloat.horizontalSpacing
        textView.topAnchor == titleLabel.topAnchor
        textView.trailingAnchor == contentView.trailingAnchor - CGFloat.horizontalMargin
        textView.bottomAnchor <= contentView.bottomAnchor - CGFloat.verticalMargin
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
