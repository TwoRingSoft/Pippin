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
    @available(iOS, deprecated: 13.0, message: "Use init(blurredViewController:material:vibrancyStyle:)")
    public required init(viewController: UIViewController, blurStyle: UIBlurEffect.Style = .light, vibrancy: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        addNewChildViewController(newChildViewController: viewController, containerView: blurView.contentView)
        viewController.view.fillSuperview()

        view.addSubview(blurView)
        blurView.fillSuperview()

        if vibrancy {
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyView.isUserInteractionEnabled = false
            blurView.contentView.addSubview(vibrancyView)
            vibrancyView.fillSuperview()
        }

        self.title = viewController.title
    }

    @available(iOS 13.0, *)
    public init(blurredViewController viewController: UIViewController, material: UIBlurEffect.Style = .systemMaterial, vibrancyStyle: UIVibrancyEffectStyle? = nil) {
        super.init(nibName: nil, bundle: nil)

        let blurEffect = UIBlurEffect(style: material)
        let blurView = UIVisualEffectView(effect: blurEffect)
        addNewChildViewController(newChildViewController: viewController, containerView: blurView.contentView)
        viewController.view.fillSuperview()

        view.addSubview(blurView)
        blurView.fillSuperview()

        if let vibrancyStyle = vibrancyStyle {
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyView.isUserInteractionEnabled = false
            blurView.contentView.addSubview(vibrancyView)
            vibrancyView.fillSuperview()
        }

        self.title = viewController.title
    }

}
