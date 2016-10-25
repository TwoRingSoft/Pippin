//
//  UIView+Layout.swift
//  McMileage
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

extension UIView {

    func fillSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = superview else { return }
        for constraint in [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ] {
                constraint.isActive = true
        }
    }

}
