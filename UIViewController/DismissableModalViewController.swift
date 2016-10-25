//
//  DismissableModalViewController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import Foundation

class DismissableModalViewController: UIViewController {

    private var closeBlock: ((Void) -> Void)?

    init(childViewController: UIViewController, onClose closeBlock: ((Void) -> Void)?) {
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white

        addChildViewController(childViewController)
        title = childViewController.title

        let titleAndCloseButtonView = UIView(frame: .zero)

        let closeButton = createButtonWithImageSetName("close", emphasisSuffix: "-filled", tintColor: .black)
        titleAndCloseButtonView.addSubview(closeButton)
        closeButton.topAnchor == titleAndCloseButtonView.topAnchor
        closeButton.bottomAnchor == titleAndCloseButtonView.bottomAnchor
        closeButton.trailingAnchor == titleAndCloseButtonView.trailingAnchor
        closeButton.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)

        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        
        titleAndCloseButtonView.addSubview(titleLabel)
        titleLabel.centerAnchors == titleAndCloseButtonView.centerAnchors
        titleLabel.trailingAnchor >= closeButton.leadingAnchor

        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        let contentView = UIView(frame: .zero)
        contentView.addSubview(childViewController.view)
        childViewController.edgeAnchors == contentView.edgeAnchors
        let stack = UIStackView(arrangedSubviews: [ titleAndCloseButtonView, contentView ])
        stack.axis = .vertical
        view.addSubview(stack)
        titleAndCloseButtonView.widthAnchor == stack.widthAnchor
        stack.edgeAnchors == self.edgeAnchors

        self.closeBlock = closeBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func closeButtonTapped() {
        closeBlock?()
    }

}
