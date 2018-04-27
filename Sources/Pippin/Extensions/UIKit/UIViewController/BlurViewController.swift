//
//  BlurViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

/// A `UIViewController` subclass that displays a child view controller with an active blur background.
public final class BlurViewController: UIViewController {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Instantiate a new `BlurViewController` with a child view controller and a blur style.
    ///
    /// - Parameters:
    ///   - viewController: the view controller to show with a blur.
    ///   - blurStyle: the type of blur to use.
    ///
    /// - Note: `viewController`'s subviews must have transparent background.
    public required init(viewController: UIViewController, blurStyle: UIBlurEffectStyle = .light) {
        super.init(nibName: nil, bundle: nil)

        addNewChildViewController(newChildViewController: viewController)

        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.contentView.addSubview(viewController.view)
        viewController.view.fillSuperview()

        view.addSubview(blurView)
        blurView.fillSuperview()
    }

}
