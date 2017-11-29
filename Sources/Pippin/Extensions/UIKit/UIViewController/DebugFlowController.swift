//
//  DebugFlowController.swift
//  Pippin
//
//  Created by Andrew McKnight on 4/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import UIKit

public enum DebugFlowControllerError: Error {
    case databaseExportError(message: String, underlyingError: Error)
    case noAppsToImportDatabase
}

public protocol DebugFlowControllerDelegate {
    func exportedDatabaseData() -> Data?
    func failedToExportDatabase(error: DebugFlowControllerError)
    func debugFlowControllerWantsToGenerateTestModels(debugFlowControllerError: DebugFlowController)
}

public class DebugFlowController: NSObject {

    private weak var presentingVC: UIViewController!
    private var databaseFilename: String!
    private var delegate: DebugFlowControllerDelegate!

    var documentInteractionController: UIDocumentInteractionController!

    public init(delegate: DebugFlowControllerDelegate) {
        super.init()
        self.delegate = delegate
    }

}

// MARK: Public
public extension DebugFlowController {

    func displayDebugMenu(fromViewController viewController: UIViewController, databaseFilename: String, coreDataController: CoreDataController) {
        self.databaseFilename = databaseFilename
        let debugVC = DebugViewController(delegate: self, logger: nil, coreDataController: coreDataController)
        presentingVC = viewController
        viewController.present(debugVC, animated: true)
    }

}

extension DebugFlowController: DebugViewControllerDelegate {

    func debugViewControllerExported(debugViewController: DebugViewController) {
        exportDatabase(databaseFileName: databaseFilename)
    }

    func debugViewControllerCanceled(debugViewController: DebugViewController) {
        presentingVC.dismiss(animated: true)
    }

    func debugViewControllerWantsToGenerateTestModels(debugViewController: DebugViewController) {
        delegate.debugFlowControllerWantsToGenerateTestModels(debugFlowControllerError: self)
    }

}

// MARK: Private
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
