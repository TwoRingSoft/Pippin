//
//  DismissableModalViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/23/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

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
        
        let margin: CGFloat = 10
        
        [titleAndCloseButtonView, contentView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [
            titleAndCloseButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleAndCloseButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleAndCloseButtonView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            contentView.topAnchor.constraint(equalTo: titleAndCloseButtonView.bottomAnchor, constant: margin),
            contentView.leadingAnchor.constraint(equalTo: titleAndCloseButtonView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: titleAndCloseButtonView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin),
        ].forEach { $0.isActive = true }

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
        
        [closeButton, titleLabel].forEach {
            titleAndCloseButtonView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [
            titleLabel.topAnchor.constraint(equalTo: titleAndCloseButtonView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleAndCloseButtonView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleAndCloseButtonView.leadingAnchor, constant: CGFloat.horizontalSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -CGFloat.horizontalSpacing),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.topAnchor.constraint(greaterThanOrEqualTo: titleAndCloseButtonView.topAnchor),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: titleAndCloseButtonView.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.trailingAnchor.constraint(equalTo: titleAndCloseButtonView.trailingAnchor, constant: -CGFloat.horizontalSpacing),
        ].forEach { $0.isActive = true }
        
        return titleAndCloseButtonView
    }
}
