//
//  BlurViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public final class BlurViewController: UIViewController {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required init(viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        addNewChildViewController(newChildViewController: viewController)

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.addSubview(viewController.view)
        viewController.view.fillSuperview()

        view.addSubview(blurView)
        blurView.fillSuperview()
    }

}
