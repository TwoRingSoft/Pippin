//
//  TextViewCell.swift
//  Pods
//
//  Created by Andrew McKnight on 12/7/17.
//

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

        [titleLabel, textView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat.horizontalMargin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
            textView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: CGFloat.horizontalSpacing),
            textView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CGFloat.horizontalMargin),
            textView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
        ].forEach { $0.isActive = true }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
