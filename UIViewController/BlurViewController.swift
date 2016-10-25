//
//  BlurViewController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/25/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

final class BlurViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        self.setUpBackground()
        fillWithChildViewController(childViewController: viewController)
    }

}

fileprivate extension BlurViewController {

    // MARK: Private

    func setUpBackground() {
        let blurView = UIToolbar(frame: .zero)
        blurView.barStyle = .black
        blurView.isTranslucent = true
        view.addSubview(blurView)
        blurView.fillSuperview()
    }

}
