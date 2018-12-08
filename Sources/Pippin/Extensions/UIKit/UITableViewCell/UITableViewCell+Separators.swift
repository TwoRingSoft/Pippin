//
//  UITableViewCell+Separators.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/14/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    
    /// Add a separator to the bottom of the receiving `UITableViewCell`.
    ///
    /// - Parameters:
    ///   - thickness: How thick the separator should be. Defaults to Pippin's `UIScreen.main.hairlineWidth`.
    ///   - backgroundColor: The background color of the separator. Default is `UIColor.black`.
    ///   - insets: The insets to use for positioning. `UIEdgeInsets.top` is ignored. Default is `UIEdgeInsets.zero`.
    ///   - pinnedToTop: if `false`, the separator is pinned to the bottom of the cell and `insets.bottom` is used for spacing; if `true`, the separator is pinned to the top of the cell and `insets.top` is used for spacing.
    func addSeparator(thickness: CGFloat = UIScreen.main.hairlineWidth, backgroundColor: UIColor = .black, insets: UIEdgeInsets = .zero, pinnedToTop: Bool = false) {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = backgroundColor
        contentView.addSubview(separator)
        let verticalConstraint: NSLayoutConstraint
        if pinnedToTop {
            verticalConstraint = separator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top)
        } else {
            verticalConstraint = separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
        }
        separator.translatesAutoresizingMaskIntoConstraints = false
        [
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            separator.heightAnchor.constraint(equalToConstant: thickness),
            verticalConstraint,
        ].forEach { $0.isActive = true }
    }
    
}
