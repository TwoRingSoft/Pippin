//
//  SwiftMessagesAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/22/17.
//

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

public final class SwiftMessagesAdapter: NSObject {}

extension SwiftMessagesAdapter: Alerter {

    public func initialize() {}

    public func showAlert(title: String, message: String, type: AlertType, dismissal: AlertDismissal, occlusion: AlertOcclusion) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(type.swiftMessagesType())
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        var config = SwiftMessages.Config()
        config.duration = dismissal == .interactive ? .forever : .automatic
        config.dimMode = occlusion == .strong ? .gray(interactive: true) : .none
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: config, view: view)
    }

    public func showConfirmationAlert(title: String, message: String, type: AlertType, confirmationCompletion: @escaping EmptyBlock) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(type.swiftMessagesType())
        view.configureDropShadow()
        view.buttonTapHandler = { button in
            confirmationCompletion()
        }
        view.configureContent(title: title, body: message)
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }

}
