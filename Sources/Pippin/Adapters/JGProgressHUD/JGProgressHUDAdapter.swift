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
    public var environment: Environment?
    private var completion: EmptyBlock?

    public override init() {
        super.init()
        window.rootViewController = rootView
        window.windowLevel = WindowLevel.indicator.windowLevel()
        indicator.delegate = self
    }
    
    public func show(withText text: String? = nil, completion: EmptyBlock? = nil) {
        indicator.textLabel.text = text
        self.completion = completion
        display()
    }

    public func show(withAttributedText attributedText: NSAttributedString? = nil, completion: EmptyBlock? = nil) {
        indicator.textLabel.attributedText = attributedText
        self.completion = completion
        display()
    }

    public func hide(completion: EmptyBlock? = nil) {
        self.completion = completion
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
    public func progressHUD(_ progressHUD: JGProgressHUD, didPresentIn view: UIView) {
        completion?()
    }
    
    public func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        window.isHidden = true
        completion?()
    }
}

// MARK: Debuggable
extension JGProgressHUDAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let titleLabel = UILabel.label(withText: "ActivityIndicator:", font: environment!.fonts.title, textColor: .black)
        
        let button = UIButton(type: .custom)
        button.setTitle("Show activity indicator", for: .normal)
        button.addTarget(self, action: #selector(showTestActivityIndicatorPressed), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, button])
        stack.axis = .vertical
        stack.spacing = 20
        
        return stack
    }
    
    @objc private func showTestActivityIndicatorPressed() {
        show(withText: "Wait...")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.hide()
        }
    }
}

// MARK: Private
private extension JGProgressHUDAdapter {
    func display() {
        window.isHidden = false
        indicator.show(in: rootView.view, animated: true)
    }
}
