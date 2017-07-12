//
//  UIView+Layout.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

extension UIView {

    func fillSuperview(insets: UIEdgeInsets = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = superview else { return }
        for constraint in [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
            ] {
                constraint.isActive = true
        }
    }

}
