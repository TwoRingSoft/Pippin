//
//  UIViewController+ChildViewControllers.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public extension UIViewController {
    func fillWithChildViewController(childViewController: UIViewController) {
        addNewChildViewController(newChildViewController: childViewController)
        childViewController.view.fillSuperview()
    }

    /// Call on the instance of the parent view controller to which to add the child view controller.
    ///
    /// - Parameters:
    ///   - childViewController: The `UIViewController` that will be contained.
    ///   - containerView: An optional subview of the parent `UIViewController` to which the child `UIViewController`'s `view` will be added as a subview. If one is not provided, the parent's `view` is used as container.
    func addNewChildViewController(newChildViewController childViewController: UIViewController, containerView: UIView? = nil) {
        let resolvedView: UIView = containerView ?? view
        resolvedView.addSubview(childViewController.view)
        addChild(childViewController)
    }

    /// Call on the instance of the child view controller to remove
    func removeAsChildViewController() {
        view.removeFromSuperview()
        removeFromParent()
    }
}
