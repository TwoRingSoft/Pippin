//
//  UIView+Layout.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

public extension UIView {
    func fillSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ].forEach { $0.isActive = true }
    }
    
    func fillLayoutMargins(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        [
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor, constant: insets.left),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor, constant: -insets.right),
            layoutMarginsGuide.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant:insets.top),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor, constant: -insets.bottom)
        ].forEach { $0.isActive = true }
    }

    @available(iOS 11.0, *)
    func fillSafeArea(inViewController viewController: UIViewController, insets: UIEdgeInsets = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        [
            topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
        ].forEach { $0.isActive = true }
    }
}
