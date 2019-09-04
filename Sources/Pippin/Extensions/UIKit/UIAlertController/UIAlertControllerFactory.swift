//
//  UIAlertControllerFactory.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

@objc public extension UIViewController {

    func confirmDestructiveAction(actionName: String, message: String, cancelLabel: String, actionBlock: @escaping (() -> ())) {
        showConfirmationAlert(withTitle: "Confirm \(actionName)", message: message, confirmTitle: "Yes, \(actionName)", cancelTitle: cancelLabel, style: .actionSheet, completion: { confirmed in
            if confirmed {
                actionBlock()
            }
        })
    }

    func showAlert(withTitle title: String? = nil, message: String? = nil, confirmTitle: String = "OK", completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive, handler: { action in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }

    func showConfirmationAlert(withTitle title: String? = nil, message: String? = nil, confirmTitle: String = "OK", cancelTitle: String = "Cancel", style: UIAlertController.Style = .alert, completion: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { action in
            completion?(true)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { action in
            completion?(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
