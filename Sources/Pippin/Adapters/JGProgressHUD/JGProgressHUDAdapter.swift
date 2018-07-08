//
//  JGProgressHUDAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 5/24/18.
//

import Foundation
import JGProgressHUD
import UIKit

public final class JGProgressHUDAdapter: NSObject {
    fileprivate let indicator = JGProgressHUD(style: .dark)
    fileprivate let window = UIWindow(frame: UIScreen.main.bounds)
    fileprivate let rootView = UIViewController(nibName: nil, bundle: nil)

    public override init() {
        super.init()
        window.rootViewController = rootView
        window.windowLevel = UIWindowLevelAlert
        indicator.delegate = self
    }
}

extension JGProgressHUDAdapter: ActivityIndicator {

    public func show(withText text: String? = nil) {
        indicator.textLabel.text = text
        window.isHidden = false
        indicator.show(in: rootView.view, animated: true)
    }

    public func hide() {
        indicator.dismiss(animated: true)
    }

}

extension JGProgressHUDAdapter: JGProgressHUDDelegate {

    public func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        window.isHidden = true
    }

}
