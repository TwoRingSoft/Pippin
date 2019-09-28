//
//  DebugFlowController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Pippin
import UIKit

public enum DebugFlowError: Error {
    case databaseExportError(message: String, underlyingError: Error)
    case noAppsToImportDatabase
}

public class DebugFlowController: NSObject, DebugMenuPresenter {

    private weak var presentingVC: UIViewController!
    private var databaseFilename: String
    private var debugWindow: DebugWindow?
    public var environment: Environment?
    private var assetBundle: Bundle?
    private var buttonTintColor: UIColor
    private var buttonStartLocation: CGPoint

    var documentInteractionController: UIDocumentInteractionController!

    public init(databaseFileName: String, assetBundle: Bundle? = nil, buttonTintColor: UIColor = .black, buttonStartLocation: CGPoint = .zero) {
        self.databaseFilename = databaseFileName
        self.assetBundle = assetBundle
        self.buttonTintColor = buttonTintColor
        self.buttonStartLocation = buttonStartLocation
        super.init()
    }

    public func installViews() {
        debugWindow = DebugWindow(frame: UIScreen.main.bounds)
        debugWindow?.windowLevel = WindowLevel.debugging.windowLevel()
        debugWindow?.isHidden = false
        debugWindow?.rootViewController = DebugViewController(delegate: self, environment: environment!, assetBundle: assetBundle, buttonTintColor: buttonTintColor, buttonStartLocation: buttonStartLocation)
    }

}

extension DebugFlowController: DebugViewControllerDelegate {
    
    func debugViewControllerDisplayedMenu(debugViewController: DebugViewController) {
        debugWindow?.menuDisplayed = true
    }
    
    func debugViewControllerHidMenu(debugViewController: DebugViewController) {
        debugWindow?.menuDisplayed = false
    }

}
