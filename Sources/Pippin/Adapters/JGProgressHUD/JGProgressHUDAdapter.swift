//
//  JGProgressHUDAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 5/24/18.
//

import Foundation
import JGProgressHUD
import UIKit

public final class JGProgressHUDAdapter: NSObject, ActivityIndicator {
    fileprivate let indicator = JGProgressHUD(style: .dark)
    fileprivate let window = UIWindow(frame: UIScreen.main.bounds)
    fileprivate let rootView = UIViewController(nibName: nil, bundle: nil)
    public var logger: Logger?

    public override init() {
        super.init()
        window.rootViewController = rootView
        window.windowLevel = UIWindowLevelAlert
        indicator.delegate = self
    }
    
    public func show(withText text: String? = nil) {
        indicator.textLabel.text = text
        display()
    }

    public func show(withAttributedText attributedText: NSAttributedString? = nil) {
        indicator.textLabel.attributedText = attributedText
        display()
    }

    public func hide() {
        indicator.dismiss(animated: true)
    }
}

// MARK: Themeable
extension JGProgressHUDAdapter: Themeable {
    public func appearanceContainerClassHierarchy() -> [UIAppearanceContainer.Type] {
        return [] // couldn't find a hierarchy that would make this work!
    }
}

// MARK: JGProgressHUDDelegate
extension JGProgressHUDAdapter: JGProgressHUDDelegate {
    public func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        window.isHidden = true
    }
}

// MARK: Private
private extension JGProgressHUDAdapter {
    func display() {
        window.isHidden = false
        indicator.show(in: rootView.view, animated: true)
    }
}
