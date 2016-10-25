//
//  UIAlertControllerFactory.swift
//  McMileage
//
//  Created by Andrew McKnight on 10/25/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

extension UIViewController {

    func confirmDestructiveAction(actionName: String, message: String, cancelLabel: String, actionBlock: @escaping ((Void) -> Void)) {
        let alert = UIAlertController(title: "Confirm \(actionName)", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes, \(actionName)", style: .destructive, handler: { action in
            actionBlock()
        }))
        alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
