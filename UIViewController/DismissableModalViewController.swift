//
//  DismissableModalViewController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

class DismissableModalViewController: UIViewController {

    private var closeBlock: ((Void) -> Void)?

    init(childViewController: UIViewController, titleFont: UIFont, onClose closeBlock: ((Void) -> Void)?) {
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .clear

        addChildViewController(childViewController)
        title = childViewController.title

        let titleAndCloseButtonView = UIView(frame: .zero)

        let closeButton = createButtonWithImageSetName("close", emphasisSuffix: "-filled", tintColor: .black)
        titleAndCloseButtonView.addSubview(closeButton)
        closeButton.topAnchor == titleAndCloseButtonView.topAnchor
        closeButton.bottomAnchor == titleAndCloseButtonView.bottomAnchor
        closeButton.trailingAnchor == titleAndCloseButtonView.trailingAnchor - 10
        closeButton.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        let titleLabel = label(withText: title ?? "", font: titleFont)
        
        titleAndCloseButtonView.addSubview(titleLabel)
        titleLabel.centerYAnchor == titleAndCloseButtonView.centerYAnchor
        titleLabel.leadingAnchor == titleAndCloseButtonView.leadingAnchor + 10
        titleLabel.trailingAnchor >= closeButton.leadingAnchor

        let contentView = UIView(frame: .zero)
        contentView.addSubview(childViewController.view)
        childViewController.view.fillSuperview()

        let stack = UIStackView(arrangedSubviews: [
            titleAndCloseButtonView,
            contentView
        ])
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fill
        view.addSubview(stack)
        titleAndCloseButtonView.widthAnchor == stack.widthAnchor
        stack.fillSuperview(insets: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))

        self.closeBlock = closeBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func closeButtonTapped() {
        closeBlock?()
    }

}
