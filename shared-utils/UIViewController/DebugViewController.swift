//
//  DebugViewController.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Anchorage
import UIKit

protocol DebugViewControllerDelegate {
    func debugViewControllerCanceled(debugViewController: DebugViewController)
    func debugViewControllerExported(debugViewController: DebugViewController)
    func debugViewControllerWantsToGenerateTestModels(debugViewController: DebugViewController)
}

class DebugViewController: UIViewController {

    private var delegate: DebugViewControllerDelegate!
    private var logger: Logger?
    private var coreDataController: CoreDataController!

    init(delegate: DebugViewControllerDelegate, logger: Logger?, coreDataController: CoreDataController) {
        self.delegate = delegate
        self.logger = logger
        self.coreDataController = coreDataController
        super.init(nibName: nil, bundle: nil)

        let exportButton = UIButton(frame: .zero)
        exportButton.configure(title: "Export Database", target: self, selector: #selector(exportPressed))
        let importButton = UIButton(frame: .zero)
        importButton.configure(title: "Import Database", target: self, selector: #selector(importPressed))
        let generateButton = UIButton(frame: .zero)
        generateButton.configure(title: "Generate Test Models", target: self, selector: #selector(generatePressed))
        let deleteButton = UIButton(frame: .zero)
        deleteButton.configure(title: "Delete Database", target: self, selector: #selector(deletePressed))
        let cancelButton = UIButton(frame: .zero)
        cancelButton.configure(title: "Cancel", target: self, selector: #selector(cancelPressed))
        let stack = UIStackView(arrangedSubviews: [exportButton, importButton, generateButton, deleteButton, cancelButton])
        stack.axis = .vertical

        view.addSubview(stack)

        stack.centerAnchors == view.centerAnchors

        view.backgroundColor = .white

        modalPresentationStyle = .formSheet
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func exportPressed() {
        delegate.debugViewControllerExported(debugViewController: self)
    }

    @objc func deletePressed() {
        let url = FileManager.url(forApplicationSupportFile: "InformedConsent.sqlite")
        let shmURL = FileManager.url(forApplicationSupportFile: "InformedConsent.sqlite-shm")
        let walURL = FileManager.url(forApplicationSupportFile: "InformedConsent.sqlite-wal")
        do {
            try FileManager.default.removeItem(at: url)
            try FileManager.default.removeItem(at: shmURL)
            try FileManager.default.removeItem(at: walURL)
            fatalError("Restarting to complete database removal.")
        } catch {
            showAlert(withTitle: "Error", message: String(format: "Failed to delete database file: %@.", String(describing: error)))
        }
    }

    @objc func generatePressed() {
        delegate.debugViewControllerWantsToGenerateTestModels(debugViewController: self)
    }

    @objc func importPressed() {
        do {
            try present(DatabaseFixturePickerViewController(coreDataController: coreDataController, logger: logger), animated: true)
        } catch {
            showAlert(withTitle: "Error", message: String(format: "Failed to initialize list of fixtures: %@.", String(describing: error)))
        }
    }

    @objc func cancelPressed() {
        delegate.debugViewControllerCanceled(debugViewController: self)
    }

}
