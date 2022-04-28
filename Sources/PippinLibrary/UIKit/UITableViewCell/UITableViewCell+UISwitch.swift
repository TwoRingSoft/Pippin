//
//  UITableViewCell+UISwitch.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public let switchTableViewCellReuseIdentifier = "UITableViewCell+UISwitch"

/**
 A `UITableViewCell` subclass providing a `UISwitch` on the right and a title label on the left. By default the label's `numberOfLines` is not set to 0, but it is layed out such that the label may extend to multiple lines and leave the switch at the top.
 */
public class SwitchTableViewCell: UITableViewCell {

    public let `switch` = UISwitch(frame: .zero)
    public let titleLabel = UILabel(frame: .zero)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [`switch`, titleLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat.horizontalMargin),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
            titleLabel.firstBaselineAnchor.constraint(equalTo: `switch`.firstBaselineAnchor),

            `switch`.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat.verticalMargin),
            `switch`.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: CGFloat.horizontalSpacing),
            `switch`.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CGFloat.horizontalMargin),
            `switch`.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CGFloat.verticalMargin),
        ].forEach { $0.isActive = true }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
