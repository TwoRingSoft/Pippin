//
//  TextFieldTableViewCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public let textFieldTableViewCellReuseIdentifier = "TextFieldTableViewCell"

/**
 A `UITableViewCell` subclass providing a label on the left and a text field on the right. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the text field at the top.
 */
public class TextFieldTableViewCell: UITableViewCell {

    public let textField = UITextField(frame: .zero)
    public let titleLabel = UILabel(frame: .zero)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [textField, titleLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat.horizontalMargin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: CGFloat.horizontalSpacing),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CGFloat.horizontalMargin),
            textField.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            textField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
        ].forEach { $0.isActive = true }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
