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
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)

        let stack = UIStackView(arrangedSubviews: [titleAndCloseButtonView, contentView])
        stack.axis = .vertical
        view.addSubview(stack)
        stack.fillSafeArea(inViewController: self, insets: .all(10))

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
        let closeButton = UIButton.button(withImageSetName: "close", emphasisSuffix: "-filled", tintColor: tintColor, imageBundle: imageBundle)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let titleLabel = UILabel.label(withText: title ?? "", font: titleFont, textColor: tintColor, alignment: .center)
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.allowsDefaultTighteningForTruncation = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        stack.spacing = CGFloat.horizontalSpacing
        stack.alignment = .top

        return stack
    }
}
