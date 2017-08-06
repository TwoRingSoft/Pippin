//
//  DatabaseFixturePickerViewController.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import UIKit

class DatabaseFixturePickerViewController: UIViewController {

    var fixtures: [URL]!

    init(_: Any? = nil) throws {
        super.init(nibName: nil, bundle: nil)

        if let path = Bundle.main.resourcePath {
            let fixturesDirectoryURL = URL(fileURLWithPath: (path as NSString).appendingPathComponent("fixtures"))
            do {
                fixtures = try FileManager.default.contentsOfDirectory(at: fixturesDirectoryURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(rawValue: 0))
            } catch {
                Logger.logDebug(message: String(format:"[%@] Failed to retrieve contents of directory %@: %@.", instanceType(self), fixturesDirectoryURL.path, String(describing: error)))
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

extension DatabaseFixturePickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fixtureName = fixtures[indexPath.row]
        let fixtureSQLitePath = fixtureName.appendingPathComponent(Bundle.getAppName()).appendingPathExtension("sqlite").path

        CoreDataController.importFromSQLitePath(sqlitePath: fixtureSQLitePath) { (success, confirmation) in
            if success {
                self.showConfirmationAlert(withTitle: nil, message: "The app must now close to finish the import. Relaunch to continue.", confirmTitle: "OK, Restart!", cancelTitle: "Cancel", style: .alert, completion: { (confirmed) in
                    confirmation(confirmed)
                })
            } else {
                self.showAlert(withTitle: "Error", message: "Failed to import data.")
                confirmation(false)
            }
        }
    }

}
