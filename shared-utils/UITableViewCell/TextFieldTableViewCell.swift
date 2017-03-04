//
//  TextFieldTableViewCell.swift
//  Trigonometry
//
//  Created by Andrew McKnight on 12/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

class TextFieldTableViewCell: UITableViewCell {

    static let reuseIdentifier = "TextFieldTableViewCell"

    var title: String!

    let textField = UITextField(frame: .zero)
    let titleLabel = UILabel(frame: .zero)

    init(title: String) {
        super.init(style: .default, reuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        self.title = title
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: UI Setup

extension TextFieldTableViewCell {

    func setUpUI() {
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)

        textField.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [ titleLabel, textField ])
        stack.axis = .horizontal
        stack.spacing = 20

        contentView.addSubview(stack)
        stack.horizontalAnchors == contentView.horizontalAnchors + 15
        stack.verticalAnchors == contentView.verticalAnchors + 5

    }

}
