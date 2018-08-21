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
    
    static let types: [AlertType] = [.error, .info, .warning, .success]

    func name() -> String {
        switch self {
        case .success: return "Success"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
    
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
    
    static let dismissalTypes: [AlertDismissal] = [.automatic, .interactive]

    func name() -> String {
        switch self {
        case .automatic: return "Automatic"
        case .interactive: return "Interactive"
        }
    }
    
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
    
    static let occlusionTypes: [AlertOcclusion] = [.strong, .weak]
    
    func name() -> String {
        switch self {
        case .strong: return "Strong"
        case .weak: return "Weak"
        }
    }

}

public protocol Alerter: Debuggable, Themeable, EnvironmentallyConscious {
    
    func showAlert(title: String, message: String, type: AlertType, dismissal: AlertDismissal, occlusion: AlertOcclusion)
    func showConfirmationAlert(title: String, message: String, type: AlertType, confirmButtonTitle: String, confirmationCompletion: @escaping EmptyBlock)
    func hide()

}
