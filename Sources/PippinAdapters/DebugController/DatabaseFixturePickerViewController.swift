//
//  DatabaseFixturePickerViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Pippin
import UIKit

@available(iOS 11.0, *)
class DatabaseFixturePickerViewController: UIViewController {

    var fixtures: [URL]!
    private var environment: Environment
    private var logger: Logger

    init(environment: Environment, logger: Logger) throws {
        self.environment = environment
        self.logger = logger
        
        super.init(nibName: nil, bundle: nil)

        if let path = Bundle.main.resourcePath {
            let fixturesDirectoryURL = URL(fileURLWithPath: (path as NSString).appendingPathComponent("fixtures"))
            do {
                fixtures = try FileManager.default.contentsOfDirectory(at: fixturesDirectoryURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(rawValue: 0))
            } catch {
                logger.logDebug(message: String(format:"[%@] Failed to retrieve contents of directory %@: %@.", instanceType(self), fixturesDirectoryURL.path, String(describing: error)))
            }
        }

        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(table)
        table.fillSafeArea(inViewController: self)

        view.backgroundColor = .white

        modalPresentationStyle = .formSheet
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@available(iOS 11.0, *)
extension DatabaseFixturePickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fixtures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = fixtures[indexPath.row].lastPathComponent
        return cell
    }

}

@available(iOS 11.0, *)
extension DatabaseFixturePickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fixtureName = fixtures[indexPath.row]
        let fixtureSQLitePath = fixtureName.appendingPathComponent(environment.coreDataController.modelName).appendingPathExtension("sqlite").path

        environment.coreDataController.importFromSQLitePath(sqlitePath: fixtureSQLitePath) { (success, confirmation) in
            if success {
                self.environment.alerter?.showConfirmationAlert(title: "Import complete", message: "The app must now close to finish the import. Relaunch to continue.", type: .info, confirmButtonTitle: "OK, Restart!", confirmationCompletion: { () -> (Void) in
                    confirmation(true)
                })
            } else {
                self.environment.alerter?.showAlert(title: "Error", message: "Failed to import data.", type: .error, dismissal: .interactive, occlusion: .strong)
                confirmation(false)
            }
        }
    }

}
