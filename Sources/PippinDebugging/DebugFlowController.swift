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

public protocol DebugFlowControllerDelegate: class {
    func exportedDatabaseData() -> Data?
    func failedToExportDatabase(error: DebugFlowError)
    func debugFlowControllerWantsToGenerateTestModels(debugFlowController: Debugging)
    func debugFlowControllerWantsToDeleteModels(debugFlowController: Debugging)
}

public class DebugFlowController: NSObject, DebugMenuPresenter {

    private weak var presentingVC: UIViewController!
    private var databaseFilename: String
    private var delegate: DebugFlowControllerDelegate
    private var debugWindow: DebugWindow?
    public var environment: Environment?
    private var assetBundle: Bundle?
    private var buttonTintColor: UIColor
    private var buttonStartLocation: CGPoint

    var documentInteractionController: UIDocumentInteractionController!

    public init(databaseFileName: String, delegate: DebugFlowControllerDelegate, assetBundle: Bundle? = nil, buttonTintColor: UIColor = .black, buttonStartLocation: CGPoint = .zero) {
        self.delegate = delegate
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
    
    func debugViewControllerExported(debugViewController: DebugViewController) {
        exportDatabase(databaseFileName: databaseFilename)
    }
    
    func debugViewControllerWantsToDeleteModels(debugViewController: DebugViewController) {
        delegate.debugFlowControllerWantsToDeleteModels(debugFlowController: self)
    }

    func debugViewControllerWantsToGenerateTestModels(debugViewController: DebugViewController) {
        delegate.debugFlowControllerWantsToGenerateTestModels(debugFlowController: self)
    }

}

// MARK: Private
private extension DebugFlowController {

    func exportDatabase(databaseFileName: String) {
        guard let data = delegate.exportedDatabaseData() else {
            return
        }

        let url: URL
        do {
            url = try FileManager.url(forApplicationSupportFile: databaseFileName)
        } catch {
            delegate.failedToExportDatabase(error: .databaseExportError(message: "Could not get a location to which to export data.", underlyingError: error))
            return
        }

        do {
            try data.write(to: url)
        } catch {
            delegate.failedToExportDatabase(error: .databaseExportError(message: String(format: "Failed to write imported data to file: %@.", String(describing: url)), underlyingError: error))
            return
        }

        documentInteractionController = UIDocumentInteractionController(url: url)
        if !documentInteractionController.presentOpenInMenu(from: .zero, in: presentingVC.view, animated: true) {
            delegate.failedToExportDatabase(error: .noAppsToImportDatabase)
        }
    }

}
