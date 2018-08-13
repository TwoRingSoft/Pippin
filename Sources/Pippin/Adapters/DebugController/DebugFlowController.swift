//
//  DebugFlowController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
public class DebugFlowController: NSObject, Debugging {

    private weak var presentingVC: UIViewController!
    private var databaseFilename: String
    private var delegate: DebuggingDelegate
    private var debugWindow: UIWindow?
    public var environment: Environment?

    var documentInteractionController: UIDocumentInteractionController!

    public init(databaseFileName: String, delegate: DebuggingDelegate, environment: Environment) {
        self.environment = environment
        self.delegate = delegate
        self.databaseFilename = databaseFileName
        super.init()
    }

    public func installViews() {
        debugWindow = DebugWindow(frame: UIScreen.main.bounds)
        debugWindow?.windowLevel = UIWindowLevelAlert + 1
        debugWindow?.isHidden = false
        debugWindow?.rootViewController = DebugViewController(delegate: self, environment: environment!)
    }

}

@available(iOS 11.0, *)
extension DebugFlowController: DebugViewControllerDelegate {

    func debugViewControllerExported(debugViewController: DebugViewController) {
        exportDatabase(databaseFileName: databaseFilename)
    }

    func debugViewControllerCanceled(debugViewController: DebugViewController) {
        presentingVC.dismiss(animated: true)
    }

    func debugViewControllerWantsToGenerateTestModels(debugViewController: DebugViewController) {
        delegate.debugFlowControllerWantsToGenerateTestModels(debugFlowController: self)
    }

}

// MARK: Private
@available(iOS 11.0, *)
private extension DebugFlowController {

    func exportDatabase(databaseFileName: String) {
        guard let data = delegate.exportedDatabaseData() else {
            return
        }

        let url = FileManager.url(forApplicationSupportFile: databaseFileName)

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
