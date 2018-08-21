//
//  CoreDataControllerDebugging.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/20/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Foundation

public protocol CoreDataControllerDebugging {
    func coreDataControllerExported(coreDataController: CoreDataController)
    func coreDataControllerWantsToGenerateTestModels(coreDataController: CoreDataController)
    func coreDataControllerDeletedModels(coreDataController: CoreDataController)
    func coreDataControllerWantsToImportFixture(coreDataController: CoreDataController)
}

extension CoreDataController: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let databaseSectionLabel = UILabel.label(withText: "Database:", font: environment!.fonts.title)
        
        let exportButton = UIButton(frame: .zero)
        exportButton.configure(title: "Export Database", target: self, selector: #selector(exportPressed))
        let importButton = UIButton(frame: .zero)
        importButton.configure(title: "Import Database", target: self, selector: #selector(importPressed))
        let generateButton = UIButton(frame: .zero)
        generateButton.configure(title: "Generate Test Models", target: self, selector: #selector(generatePressed))
        let deleteButton = UIButton(frame: .zero)
        deleteButton.configure(title: "Delete Database", target: self, selector: #selector(deletePressed))
        
        let databaseStack = UIStackView(arrangedSubviews: [databaseSectionLabel, exportButton, importButton, generateButton, deleteButton])
        databaseStack.axis = .vertical
        
        return databaseStack
    }
}

@objc extension CoreDataController {
    
    func exportPressed() {
        debuggingDelegate?.coreDataControllerExported(coreDataController: self)
    }
    
    func deletePressed() {
        let modelName = environment!.coreDataController.modelName
        let url = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite")
        let shmURL = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite-shm")
        let walURL = FileManager.url(forApplicationSupportFile: "\(modelName).sqlite-wal")
        
        do {
            try FileManager.default.removeItem(at: url)
            try FileManager.default.removeItem(at: shmURL)
            try FileManager.default.removeItem(at: walURL)
            debuggingDelegate?.coreDataControllerDeletedModels(coreDataController: self)
        } catch {
            environment!.alerter.showAlert(title: "Error", message: String(format: "Failed to delete database file: %@.", String(describing: error)), type: .error, dismissal: .automatic, occlusion: .weak)
        }
    }
    
    func generatePressed() {
        debuggingDelegate?.coreDataControllerWantsToGenerateTestModels(coreDataController: self)
    }
    
    func importPressed() {
        debuggingDelegate?.coreDataControllerWantsToImportFixture(coreDataController: self)
    }
}
