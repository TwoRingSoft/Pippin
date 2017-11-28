//
//  TextFieldTableViewCell.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

open class TextFieldTableViewCell: UITableViewCell {

    static let reuseIdentifier = "TextFieldTableViewCell"

    public let textField = UITextField(frame: .zero)
    let titleLabel = UILabel(frame: .zero)

    public init(title: String, font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)) {
        super.init(style: .default, reuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        setUpUI(title: title, font: font)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: UI Setup
public extension TextFieldTableViewCell {

    func setUpUI(title: String, font: UIFont) {
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)

        textField.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [ titleLabel, textField ])
        stack.axis = .horizontal
        stack.spacing = 20

        contentView.addSubview(stack)
        stack.horizontalAnchors == contentView.horizontalAnchors + 15
        stack.verticalAnchors == contentView.verticalAnchors + 5

    }

}
