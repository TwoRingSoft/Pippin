//
//  UIViewController+ChildViewControllers.swift
//  PeakFinder
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

extension UIViewController {

    func fillWithChildViewController(childViewController: UIViewController) {
        self.view.addSubview(childViewController.view)

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        for constraint in [
            childViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ] {
                constraint.isActive = true
        }


        self.addChildViewController(childViewController)
    }

    /// Call on the instance of the parent view controller to add the child to
    func addNewChildViewController(newChildViewController childViewController: UIViewController) {
        self.view.addSubview(childViewController.view)
        self.addChildViewController(childViewController)
    }

    /// Call on the instance of the child view controller to remove
    func removeAsChildViewController() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
