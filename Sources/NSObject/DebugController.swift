//
//  DebugController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 4/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

class DebugController: NSObject {

    weak var presentingVC: UIViewController!

    var documentInteractionController: UIDocumentInteractionController!

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
        let data = CoreDataController.exportData()
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
        let url = URL(fileURLWithPath: applicationSupportDirectory.appendingPathComponent(databaseFileName))

        do {
            try data.write(to: url)
        } catch {
            DoughLogController.logError(message: String(format: "[%@] Failed to write imported data to %@.", instanceType(self), String(describing: url)), error: error)
            return
        }

        documentInteractionController = UIDocumentInteractionController(url: url)
        if !documentInteractionController.presentOpenInMenu(from: .zero, in: presentingVC.view, animated: true) {
            DoughLogController.logInfo(message: String(format: "[%@] Nothing to display in document interaction controller.", instanceType(self)))
        }
    }

}
