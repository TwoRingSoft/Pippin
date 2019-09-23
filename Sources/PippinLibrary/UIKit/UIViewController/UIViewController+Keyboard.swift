//
//  UIViewController+Keyboard.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/11/17.
//

import UIKit

public extension UIViewController {
    /**
     When the keyboard's frame changes, provides the frame to a block that can
     update autolayout constraints, and then animates the update to the layout
     using other animation information extracted from the notification.
     */
    func animateLayout(afterNotification notification: Notification, keyboardHandler: (_ keyboardFrame: CGRect) -> (Void)) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHandler(frame)

        guard let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        let curve = UIView.AnimationOptions(rawValue: curveValue.uintValue)
        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
