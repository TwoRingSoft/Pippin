//
//  TransparentModalPresentingViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/30/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

/**
    Using `present(viewController:animated:completion:` does not allow for transparent views to see the views underneath.
 
    Provide a fully finished UIViewController instance to this view controller's init, then call `presentTransparently(animated:completion:)` to present the objective view controller. Use `dismiss(animated:completion:)` to hide.
 */
public class TransparentModalPresentingViewController: UIViewController {

    var addStopBlurVCTopConstraint: NSLayoutConstraint!
    var addStopBlurVCBottomConstraint: NSLayoutConstraint!

    var childViewController: UIViewController!

    public init(childViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.childViewController = childViewController
        setUpUI(childViewController: childViewController)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
public extension TransparentModalPresentingViewController {

    func presentTransparently(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        animateViewWithConstraintConstant(constant: 0, animated: animated, completion: { finished in
            self.view.isUserInteractionEnabled = true
            completion?(finished)
        })
    }

    func dismissTransparently(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        animateViewWithConstraintConstant(constant: view.bounds.height, animated: animated, completion: { finished in
            self.view.isUserInteractionEnabled = false
            completion?(finished)
        })
    }

}

// MARK: Private
private extension TransparentModalPresentingViewController {

    func setUpUI(childViewController: UIViewController) {
        view.isUserInteractionEnabled = false

        addNewChildViewController(newChildViewController: childViewController)

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        addStopBlurVCTopConstraint = childViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height)
        addStopBlurVCBottomConstraint = childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.bounds.height)
        [
            addStopBlurVCTopConstraint,
            addStopBlurVCBottomConstraint,
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ].forEach { $0?.isActive = true }
        
        view.layoutSubviews()
    }

    func animateViewWithConstraintConstant(constant: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        addStopBlurVCTopConstraint.constant = constant
        addStopBlurVCBottomConstraint.constant = constant

        if !animated {
            view.layoutSubviews()
            completion?(true)
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.layoutSubviews()
        }, completion: completion)
    }

}
