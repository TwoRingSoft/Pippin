//
//  DismissableModalViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

public class DismissableModalViewController: UIViewController {

    private var closeBlock: (() -> ())?
    private let contentView = UIView(frame: .zero)

    public init(childViewController: UIViewController, titleFont: UIFont, backgroundColor: UIColor = .clear, tintColor: UIColor = .white, imageBundle: Bundle = Bundle(for: DismissableModalViewController.self), insets: UIEdgeInsets = .zero, onClose closeBlock: (() -> ())? = nil) {
        super.init(nibName: nil, bundle: nil)

        title = childViewController.title
        
        view.backgroundColor = backgroundColor

        addNewChildViewController(newChildViewController: childViewController, containerView: contentView)
        childViewController.view.fillSuperview()

        let titleAndCloseButtonView = headerView(tintColor: tintColor, imageBundle: imageBundle, titleFont: titleFont)
        titleAndCloseButtonView.setContentHuggingPriority(.required, for: .vertical)
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        view.addSubview(titleAndCloseButtonView)
        view.addSubview(contentView)
        
        let margin: CGFloat = 10
        
        titleAndCloseButtonView.horizontalAnchors == view.horizontalAnchors
        titleAndCloseButtonView.topAnchor == view.topAnchor + margin
        
        contentView.topAnchor == titleAndCloseButtonView.bottomAnchor + margin
        contentView.horizontalAnchors == titleAndCloseButtonView.horizontalAnchors
        contentView.bottomAnchor == view.bottomAnchor - margin

        self.closeBlock = closeBlock
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc extension DismissableModalViewController {
    func closeButtonTapped() {
        guard let closeBlock = closeBlock else { return }
        DispatchQueue.main.async(execute: closeBlock)
    }
}

private extension DismissableModalViewController {
    func headerView(tintColor: UIColor, imageBundle: Bundle, titleFont: UIFont) -> UIView {
        let titleAndCloseButtonView = UIView(frame: .zero)
        titleAndCloseButtonView.setContentHuggingPriority(.required, for: .vertical)
        titleAndCloseButtonView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let closeButton = UIButton.button(withImageSetName: "close", emphasisSuffix: "-filled", tintColor: tintColor, imageBundle: imageBundle)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let titleLabel = UILabel.label(withText: title ?? "", font: titleFont, textColor: tintColor, alignment: .center)
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        titleAndCloseButtonView.addSubview(closeButton)
        titleAndCloseButtonView.addSubview(titleLabel)
        
        titleLabel.topAnchor == titleAndCloseButtonView.topAnchor
        titleLabel.bottomAnchor == titleAndCloseButtonView.bottomAnchor
        titleLabel.leadingAnchor == titleAndCloseButtonView.leadingAnchor + CGFloat.horizontalSpacing
        titleLabel.trailingAnchor == closeButton.leadingAnchor - CGFloat.horizontalSpacing
        
        closeButton.centerYAnchor == titleLabel.centerYAnchor
        closeButton.topAnchor >= titleAndCloseButtonView.topAnchor
        closeButton.bottomAnchor <= titleAndCloseButtonView.bottomAnchor
        closeButton.widthAnchor == 35
        closeButton.heightAnchor == closeButton.widthAnchor
        closeButton.trailingAnchor == titleAndCloseButtonView.trailingAnchor - CGFloat.horizontalSpacing
        
        return titleAndCloseButtonView
    }
}
