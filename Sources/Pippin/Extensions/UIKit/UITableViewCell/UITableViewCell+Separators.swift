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
    func addSeparator(thickness: CGFloat = UIScreen.main.hairlineWidth, backgroundColor: UIColor = .black, insets: UIEdgeInsets = .zero) {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = backgroundColor
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        [
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            separator.heightAnchor.constraint(equalToConstant: thickness),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
        ].forEach { $0.isActive = true }
    }
    
}
