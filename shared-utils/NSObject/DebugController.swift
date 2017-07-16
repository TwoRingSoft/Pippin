//
//  DebugController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

enum DebugControllerError: Error {
    case databaseExportError(message: String, underlyingError: Error)
    case noAppsToImportDatabase
}

protocol DebugControllerDelegate {
    func exportedDatabaseData() -> Data?
    func failedToExportDatabase(error: DebugControllerError)
}

class DebugController: NSObject {

    private weak var presentingVC: UIViewController!
    private var delegate: DebugControllerDelegate!

    var documentInteractionController: UIDocumentInteractionController!

    init(delegate: DebugControllerDelegate) {
        super.init()
        self.delegate = delegate
    }

    func displayDebugMenu(fromViewController viewController: UIViewController, databaseFilename: String) {
        presentingVC = viewController
        let alert = UIAlertController(title: "\(Bundle.getAppName()) Debugging", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Export Database", style: .default, handler: { action in
            self.exportDatabase(databaseFileName: databaseFilename)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.presentingVC.dismiss(animated: true)
        }))
        presentingVC.present(alert, animated: true)
    }

}

// MARK: Private
private extension DebugController {

    func exportDatabase(databaseFileName: String) {
        guard let data = delegate.exportedDatabaseData() else {
            return
        }

        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
        let url = URL(fileURLWithPath: applicationSupportDirectory.appendingPathComponent(databaseFileName))

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
