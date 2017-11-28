//
//  UIViewController+ChildViewControllers.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

extension UIViewController {

    public func fillWithChildViewController(childViewController: UIViewController) {
        addNewChildViewController(newChildViewController: childViewController)
        childViewController.view.fillSuperview()
    }

    /// Call on the instance of the parent view controller to add the child to
    public func addNewChildViewController(newChildViewController childViewController: UIViewController) {
        view.addSubview(childViewController.view)
        addChildViewController(childViewController)
    }

    /// Call on the instance of the child view controller to remove
    public func removeAsChildViewController() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
