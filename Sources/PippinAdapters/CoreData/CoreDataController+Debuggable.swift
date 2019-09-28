//
//  CoreDataController+Debuggable.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/20/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Foundation
import Pippin

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
        debuggingDelegate?.exported(coreDataController: self)
    }
    
    func deletePressed() {
        debuggingDelegate?.deleteModels(coreDataController: self)
    }
    
    func generatePressed() {
        debuggingDelegate?.generateTestModels(coreDataController: self)
    }
    
    func importPressed() {
        debuggingDelegate?.importFixtures(coreDataController: self)
    }
}
