//
//  SwiftMessagesAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

import Anchorage
import Foundation
import SwiftMessages

extension AlertType {

    func swiftMessagesType() -> Theme {
        switch self {
        case .error: return .error
        case .info: return .info
        case .success: return .success
        case .warning: return .warning
        }
    }

}

public final class SwiftMessagesAdapter: NSObject, Alerter {
    
    public var environment: Environment?
    
    var styleControl: UISegmentedControl
    var typeControl: UISegmentedControl
    var dismissalControl: UISegmentedControl
    var occlusionControl: UISegmentedControl
    var showButton: UIButton
    
    override public init() {
        // set up debug controls
        styleControl = UISegmentedControl(items: ["Toast", "Confirmation"])
        typeControl = UISegmentedControl(items: AlertType.types.map { $0.name() })
        dismissalControl = UISegmentedControl(items: AlertDismissal.dismissalTypes.map { $0.name() })
        occlusionControl = UISegmentedControl(items: AlertOcclusion.occlusionTypes.map { $0.name() })
        showButton = UIButton(type: .custom)
        
        super.init()
    }

    public func showAlert(title: String, message: String, type: AlertType, dismissal: AlertDismissal, occlusion: AlertOcclusion) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(type.swiftMessagesType())
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        var config = SwiftMessages.Config()
        config.duration = dismissal == .interactive ? .forever : .automatic
        config.dimMode = occlusion == .strong ? .gray(interactive: true) : .none
        config.presentationContext = .window(windowLevel: WindowLevel.alerter.windowLevel().rawValue)
        SwiftMessages.show(config: config, view: view)
    }

    public func showConfirmationAlert(title: String, message: String, type: AlertType, confirmButtonTitle: String = NSLocalizedString("Confirm", comment: ""), confirmationCompletion: @escaping EmptyBlock) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(type.swiftMessagesType())
        view.configureDropShadow()
        view.button?.setTitle(confirmButtonTitle, for: .normal)
        view.buttonTapHandler = { button in
            confirmationCompletion()
        }
        view.configureContent(title: title, body: message)
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar.rawValue)
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }

    public func hide() {
        SwiftMessages.hide()
    }

}

extension SwiftMessagesAdapter: Themeable {
    public func appearanceContainerClassHierarchy() -> [UIAppearanceContainer.Type] {
        return [MessageView.self]
    }
}

extension SwiftMessagesAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let titleLabel = UILabel.label(withText: "Alerter:", font: environment!.fonts.title, textColor: .black)
        
        let controls = [
            styleControl,
            typeControl,
            dismissalControl,
            occlusionControl,
        ]
        
        showButton.setTitle("Show", for: .normal)
        showButton.addTarget(self, action: #selector(showTestAlert), for: .touchUpInside)
        showButton.setTitleColor(.black, for: .normal)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel] + controls as [UIView] + [showButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        controls.forEach {
            $0.selectedSegmentIndex = 0
        }
        
        return stack
    }
    
    @objc private func showTestAlert() {
        switch styleControl.selectedSegmentIndex {
        case 0:
            showAlert(title: "Test", message: "This is a test alert", type: AlertType.types[typeControl.selectedSegmentIndex], dismissal: AlertDismissal.dismissalTypes[dismissalControl.selectedSegmentIndex], occlusion: AlertOcclusion.occlusionTypes[occlusionControl.selectedSegmentIndex])
        default:
            showConfirmationAlert(title: "Test Confirmation", message: "This is a test confirmation alert", type: AlertType.types[styleControl.selectedSegmentIndex]) { () -> (Void) in
                self.hide()
            }
        }
    }
}
