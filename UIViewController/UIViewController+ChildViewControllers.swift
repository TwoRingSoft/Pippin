//
//  UIViewController+ChildViewControllers.swift
//  PeakFinder
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Cartography
import Foundation

extension UIViewController {

    func fillWithChildViewController(childViewController: UIViewController) {
        self.view.addSubview(childViewController.view)
        constrain(self.view, childViewController.view) { container, subview in
            subview.edges == container.edges
        }
        self.addChildViewController(childViewController)
    }

    func addChildViewController(childViewController childViewController: UIViewController) {
        self.view.addSubview(childViewController.view)
        self.addChildViewController(childViewController)
    }

    func removeChildViewController(childViewController childViewController: UIViewController) {
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }

}
