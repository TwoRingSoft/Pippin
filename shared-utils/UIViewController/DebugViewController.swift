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

    init(delegate: DebugViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)

        let exportButton = UIButton.button(withTitle: "Export Database", target: self, selector: #selector(exportPressed))
        let importButton = UIButton.button(withTitle: "Import Database", target: self, selector: #selector(importPressed))
        let generateButton = UIButton.button(withTitle: "Generate Test Models", target: self, selector: #selector(generatePressed))
        let cancelButton = UIButton.button(withTitle: "Cancel", target: self, selector: #selector(cancelPressed))
        let stack = UIStackView(arrangedSubviews: [exportButton, importButton, generateButton, cancelButton])
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

    @objc func generatePressed() {
        delegate.debugViewControllerWantsToGenerateTestModels(debugViewController: self)
    }

    @objc func importPressed() {
        do {
            try present(DatabaseFixturePickerViewController(), animated: true)
        } catch {
            showAlert(withTitle: "Error", message: String(format: "Failed to initialize list of fixtures: %@.", String(describing: error)))
        }
    }

    @objc func cancelPressed() {
        delegate.debugViewControllerCanceled(debugViewController: self)
    }

}
