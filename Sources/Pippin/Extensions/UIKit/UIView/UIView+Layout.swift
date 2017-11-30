//
//  UIView+Layout.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Anchorage
import UIKit

extension UIView {

    public func fillSuperview(insets: UIEdgeInsets = .zero) {
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

    public func fillSafeArea(inViewController viewController: UIViewController, insets: UIEdgeInsets = .zero) {
        let edges = edgeAnchors == viewController.view.safeAreaLayoutGuide.edgeAnchors
        edges.top.constant = insets.top
        edges.leading.constant = insets.left
        edges.trailing.constant = -insets.right
        edges.bottom.constant = -insets.bottom
    }

}
