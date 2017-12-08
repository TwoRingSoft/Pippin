//
//  TextFieldTableViewCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

public let textFieldTableViewCellReuseIdentifier = "TextFieldTableViewCell"

/**
 A `UITableViewCell` subclass providing a label on the left and a text field on the right. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the text field at the top.
 */
public class TextFieldTableViewCell: UITableViewCell {

    public let textField = UITextField(frame: .zero)
    public let titleLabel = UILabel(frame: .zero)

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)

        titleLabel.leadingAnchor == contentView.leadingAnchor + 12
        titleLabel.firstBaselineAnchor == textField.firstBaselineAnchor
        titleLabel.bottomAnchor >= contentView.bottomAnchor - 8

        textField.leadingAnchor == titleLabel.trailingAnchor + 12
        textField.trailingAnchor == contentView.trailingAnchor - 12
        textField.topAnchor == contentView.topAnchor + 8
        textField.bottomAnchor >= contentView.bottomAnchor - 8
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
