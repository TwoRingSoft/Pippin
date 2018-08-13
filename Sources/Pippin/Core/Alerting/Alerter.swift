//
//  Alerter.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/21/17.
//

import Foundation

public enum AlertType {

    case success
    case info
    case warning
    case error

}

public enum AlertDismissal {

    /**
     An alert that shows and then hides on its own.
     */
    case automatic

    /**
     An alert where the user must act to dismiss or confirm it.
    */
    case interactive

}

public enum AlertOcclusion {

    /**
     Does not shade the window or prevent user interaction.
     */
    case weak

    /**
    Shade the window and prevents user interaction until dismissed.
     */
    case strong

}

public protocol Alerter: Themeable, Loggable {
    
    func showAlert(title: String, message: String, type: AlertType, dismissal: AlertDismissal, occlusion: AlertOcclusion)
    func showConfirmationAlert(title: String, message: String, type: AlertType, confirmButtonTitle: String, confirmationCompletion: @escaping EmptyBlock)
    func hide()

}
