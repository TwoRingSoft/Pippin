//
//  DebugViewController.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Anchorage
import UIKit

@available(iOS 11.0, *)
protocol DebugViewControllerDelegate {
    func debugViewControllerExported(debugViewController: DebugViewController)
    func debugViewControllerWantsToGenerateTestModels(debugViewController: DebugViewController)
}

@available(iOS 11.0, *)
public class DebugViewController: UIViewController {

    private var delegate: DebugViewControllerDelegate!
    private var environment: Environment
    private var debugMenu: UIView!
    private var assetBundle: Bundle?

    init(delegate: DebugViewControllerDelegate, environment: Environment, assetBundle: Bundle? = nil, buttonTintColor: UIColor, buttonStartLocation: CGPoint) {
        self.delegate = delegate
        self.environment = environment
        self.assetBundle = assetBundle
        super.init(nibName: nil, bundle: nil)
        setUpUI(buttonTintColor: buttonTintColor, buttonStartLocation: buttonStartLocation)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@available(iOS 11.0, *)
@objc extension DebugViewController {

    func exportPressed() {
        delegate.debugViewControllerExported(debugViewController: self)
    }

    func deletePressed() {
        let modelName = environment.coreDataController!.modelName
        let url = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite")
        let shmURL = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite-shm")
        let walURL = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite-wal")
        
        do {
            try FileManager.default.removeItem(at: url)
            try FileManager.default.removeItem(at: shmURL)
            try FileManager.default.removeItem(at: walURL)
            showAlert(withTitle: "Complete", message: "The app needs to restart to complete deletion.") {
                fatalError("Restarting to complete database removal.")
            }
        } catch {
            environment.alerter.showAlert(title: "Error", message: String(format: "Failed to delete database file: %@.", String(describing: error)), type: .error, dismissal: .automatic, occlusion: .weak)
        }
    }

    func generatePressed() {
        delegate.debugViewControllerWantsToGenerateTestModels(debugViewController: self)
    }

    func importPressed() {
        do {
            try present(DatabaseFixturePickerViewController(coreDataController: environment.coreDataController!, logger: environment.logger), animated: true)
        } catch {
            environment.alerter.showAlert(title: "Error", message: String(format: "Failed to initialize list of fixtures: %@.", String(describing: error)), type: .error, dismissal: .automatic, occlusion: .weak)
        }
    }

    func cancelPressed() {
        debugMenu.isHidden = true
    }

    func displayPressed() {
        debugMenu.isHidden = false
    }

    func draggedDisplayButton(recognizer: UIPanGestureRecognizer) {
        guard let button = recognizer.view else { return }
        let translation = recognizer.translation(in: view)
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        recognizer.setTranslation(.zero, in: view)
    }

}

@available(iOS 11.0, *)
private extension DebugViewController {

    func setUpUI(buttonTintColor: UIColor, buttonStartLocation: CGPoint) {
        debugMenu = UIView(frame: .zero)
        debugMenu.isHidden = true
        debugMenu.backgroundColor = .white
        view.addSubview(debugMenu)
        debugMenu.fillSuperview()

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
        debugMenu.addSubview(stack)
        stack.fillSuperview()

        let displayButton = UIButton.button(withImageSetName: "debug", emphasisSuffix: "-pressed", tintColor: buttonTintColor, target: self, selector: #selector(displayPressed), imageBundle: assetBundle)
        let size: CGFloat = 50
        let padding: CGFloat = 20
        let screenBounds = UIScreen.main.bounds
        displayButton.frame = CGRect(x: buttonStartLocation.x, y: buttonStartLocation.y, width: size, height: size)
        displayButton.layer.cornerRadius = size / 2
        displayButton.layer.borderWidth = 2
        displayButton.layer.borderColor = buttonTintColor.cgColor
        view.addSubview(displayButton)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggedDisplayButton))
        displayButton.addGestureRecognizer(panGestureRecognizer)
    }

}
