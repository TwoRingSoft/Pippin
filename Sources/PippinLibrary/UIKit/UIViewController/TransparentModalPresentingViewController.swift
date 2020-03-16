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

    private var topConstraint: NSLayoutConstraint?
    private var childViewController: UIViewController

    public init(childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
        setUpUI(childViewController: childViewController)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
public extension TransparentModalPresentingViewController {

    func presentTransparently(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        toggle(display: true, animated: animated, completion: { finished in
            completion?(finished)
        })
    }

    func dismissTransparently(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        toggle(display: false, animated: animated, completion: { finished in
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

        let topConstraint = childViewController.view.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            topConstraint,
            childViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.layoutSubviews()

        self.topConstraint = topConstraint
    }

    func toggle(display: Bool, animated: Bool, completion: ((Bool) -> Void)?) {
        if let top = topConstraint {
            NSLayoutConstraint.deactivate([top])
        }

        let top: NSLayoutConstraint
        if display {
            top = childViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        } else {
            top = childViewController.view.topAnchor.constraint(equalTo: view.bottomAnchor)
        }
        topConstraint = top

        NSLayoutConstraint.activate([top])

        if !animated {
            view.layoutSubviews()
            completion?(true)
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view.layoutSubviews()
        }) { finished in
            self.view.isUserInteractionEnabled = display
            completion?(finished)
        }
    }

}
