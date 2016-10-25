//
//  BlurViewController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Cartography
import Foundation

final class BlurViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        self.setUpBackground()
        self.fillWithChildViewController(viewController)
    }

}

extension BlurViewController {

    // MARK: Private

    private func setUpBackground() {
        let blurView = UIToolbar(frame: CGRectZero)
        blurView.barStyle = .Black
        blurView.translucent = true
        view.addSubview(blurView)

        constrain(blurView, view) { blurView, view in
            blurView.edges == view.edges
        }
    }

}
