//
//  CrudViewController.swift
//  Dough
//
//  Created by Andrew McKnight on 1/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import CoreData
import UIKit

enum ListViewControllerMode {
    case editor
    case picker
}

protocol CrudViewControllerCRUDDelegate {
    func crudViewControllerWantsToCreateObject(crudViewController: CrudViewController)
    func crudViewController(crudViewController: CrudViewController, wantsToUpdate object: NSFetchRequestResult)
    func crudViewController(crudViewController: CrudViewController, wantsToDelete object: NSFetchRequestResult)
}

protocol CrudViewControllerUITableViewDelegate {
    func crudViewController(crudViewController: CrudViewController, configure cell: UITableViewCell, forObject object: NSFetchRequestResult)
    func crudViewController(crudViewController: CrudViewController, selected object: NSFetchRequestResult)
    func crudViewController(crudViewController: CrudViewController, canEdit object: NSFetchRequestResult) -> Bool
    func crudViewController(crudViewController: CrudViewController, editActionsFor tableView: UITableView) -> [UITableViewRowAction]?
    func crudViewControllerShouldShowAddItemRow(crudViewController: CrudViewController) -> Bool
    func crudViewControllerShouldShowAllowMultipleSelections(crudViewController: CrudViewController) -> Bool
}

protocol CrudViewControllerSearchDelegate {
    func crudViewController(crudViewController: CrudViewController, predicateForSearchString string: String) -> NSPredicate
}

class CrudViewController: UIViewController {

    private let cellReuseIdentifier = "CrudViewControllerCell"
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var searchField: UITextField!
    private var searchCancelButton: UIButton!
    private var searchCancelButtonWidthConstraint: NSLayoutConstraint!
    private var searchCancelButtonLeadingConstraint: NSLayoutConstraint!
    private var context: NSManagedObjectContext!
    private var crudDelegate: CrudViewControllerCRUDDelegate!
    private var tableViewDelegate: CrudViewControllerUITableViewDelegate!
    private var searchDelegate: CrudViewControllerSearchDelegate!
    private var hideAddItemRow = false
    private var tableUpdates: [String: [IndexPath]]?
    private var crudName: String!
    private var originalFetchRequestPredicate: NSPredicate?
    var logger: LogController?

    init(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, crudDelegate: CrudViewControllerCRUDDelegate, tableViewDelegate: CrudViewControllerUITableViewDelegate, searchDelegate: CrudViewControllerSearchDelegate, name: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.crudDelegate = crudDelegate
        self.tableViewDelegate = tableViewDelegate
        self.searchDelegate = searchDelegate
        self.context = context
        self.crudName = name ?? fetchRequest.entityName!
        setUpFetchedResultsController(withFetchRequest: fetchRequest)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
extension CrudViewController {

    func reloadData() {
        logger?.logDebug(message: String(format: "[%@(%@)] Reloading data using performFetch on NSFetchedResultsController: %@ and rows using reloadData on UITableView: %@.", instanceType(self), crudName, fetchedResultsController, tableView))
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            let message = String(format: "[%@(%@)] Could not perform a new fetch on NSFetchedResultsController: %@.", instanceType(self), crudName, fetchedResultsController)
            logger?.logError(message: message, error: error)
        }
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    func object(locatedAt indexPath: IndexPath) -> NSFetchRequestResult {
        return fetchedResultsController.object(at: indexPath)
    }

    func selectedRows() -> [IndexPath]? {
        return tableView.indexPathsForSelectedRows
    }

    func deselectRows(atIndexPaths indexPaths: [IndexPath]?) {
        indexPaths?.forEach { indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

// MARK: Actions
@objc extension CrudViewController {

    func addPressed() {
        crudDelegate.crudViewControllerWantsToCreateObject(crudViewController: self)
    }

    func cancelSearch() {
        resetSearch()
        searchField.text = nil
        searchField.resignFirstResponder()
    }

}

// MARK: Private
private extension CrudViewController {

    func resetSearch() {
        fetchedResultsController.fetchRequest.predicate = originalFetchRequestPredicate
        reloadData()
    }

    func setUpFetchedResultsController(withFetchRequest fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        originalFetchRequestPredicate = fetchRequest.predicate
        fetchedResultsController.delegate = self
        reloadData()
    }

    func setUpUI() {
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.allowsMultipleSelection = tableViewDelegate.crudViewControllerShouldShowAllowMultipleSelections(crudViewController: self)

        searchField = UITextField.textField(withPlaceholder: "Search")
        searchField.delegate = self
        searchField.clearButtonMode = .whileEditing
        searchField.rightViewMode = .always

        searchCancelButton = UIButton(frame: .zero)
        searchCancelButton.configure(title: "Cancel", target: self, selector: #selector(cancelSearch))
        searchCancelButton.alpha = 0

        let searchContainer = UIView(frame: .zero)
        [ searchField, searchCancelButton ].forEach { searchContainer.addSubview($0) }
        searchField.leadingAnchor == searchContainer.leadingAnchor
        searchField.heightAnchor == 36
        searchField.verticalAnchors == searchContainer.verticalAnchors

        searchCancelButton.verticalAnchors == searchField.verticalAnchors
        searchCancelButtonLeadingConstraint = searchCancelButton.leadingAnchor == searchField.trailingAnchor
        searchCancelButton.trailingAnchor == searchContainer.trailingAnchor
        searchCancelButtonWidthConstraint = searchCancelButton.widthAnchor == 0

        view.addSubview(searchContainer)
        view.addSubview(tableView)

        searchContainer.topAnchor == view.topAnchor + 10
        searchContainer.horizontalAnchors == view.horizontalAnchors + 20

        tableView.topAnchor == searchContainer.bottomAnchor + 10
        tableView.horizontalAnchors == view.horizontalAnchors
        tableView.bottomAnchor == view.bottomAnchor
    }

    func addItemRowIndexPath() -> IndexPath {
        return IndexPath(row: fetchedResultsController.fetchedObjects!.count, section: 0)
    }

    func indexPathPointsToAddObjectRow(indexPath: IndexPath) -> Bool {
        if !tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) || hideAddItemRow {
            return false
        }

        return indexPath.compare(addItemRowIndexPath()) == .orderedSame
    }

    func update(indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { break }
            addUpdate(type: type, indexPath: indexPath)
            break
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            addUpdate(type: type, indexPath: newIndexPath)
            break
        case .move:
            guard
                let indexPath = indexPath,
                let newIndexPath = newIndexPath
                else { break }

            addUpdate(type: .delete, indexPath: indexPath)
            addUpdate(type: .insert, indexPath: newIndexPath)
            break
        case .update:
            guard let indexPath = indexPath else { break }
            addUpdate(type: type, indexPath: indexPath)
            break
        }
    }

    func addUpdate(type: NSFetchedResultsChangeType, indexPath: IndexPath) {
        let updateName = name(forFetchedResultsChangeType: type)

        if tableUpdates == nil {
            tableUpdates = [ updateName: [ indexPath ]]
            return
        }

        if tableUpdates![updateName] == nil {
            tableUpdates![updateName] = [ indexPath ]
            return
        }

        tableUpdates![updateName]!.append(indexPath)
    }

    func execute(tableUpdates: [String: [IndexPath]]) {
        var performedUpdates = false
        var insertedRows = 0
        if let inserts = tableUpdates[name(forFetchedResultsChangeType: .insert)] {
            logger?.logDebug(message: String(format: "[%@(%@)] inserts: %@", instanceType(self), self.crudName, inserts))
            performedUpdates = true
            tableView.beginUpdates()
            tableView.insertRows(at: inserts, with: .automatic)
            insertedRows = inserts.count
        }

        let tableViewHasRows = tableView.numberOfRows(inSection: 0) + insertedRows > 0
        if let deletes = tableUpdates[name(forFetchedResultsChangeType: .delete)], tableViewHasRows {
            logger?.logDebug(message: String(format: "[%@(%@)] deletes: %@", instanceType(self), self.crudName, deletes))
            performedUpdates = true
            tableView.beginUpdates()
            tableView.deleteRows(at: deletes, with: .automatic)
        }

        if performedUpdates {
            tableView.endUpdates()
        }
    }

    func setTableView(toHideAddItemRow hideAddItemRow: Bool) {
        DispatchQueue.main.async {
            let constraintAnimations = {
                self.searchCancelButtonWidthConstraint.constant = hideAddItemRow ? 60 : 0
                self.searchCancelButtonLeadingConstraint.constant = hideAddItemRow ? 20 : 0
                self.view.layoutIfNeeded()
            }

            let alphaAnimations = {
                self.searchCancelButton.alpha = hideAddItemRow ? 1 : 0
            }

            if hideAddItemRow {
                UIView.animate(withDuration: 0.3, animations: constraintAnimations, completion: { completed in
                    UIView.animate(withDuration: 0.3, animations: alphaAnimations)
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: alphaAnimations, completion: { completed in
                    UIView.animate(withDuration: 0.3, animations: constraintAnimations)
                })
            }

            self.hideAddItemRow = hideAddItemRow
            self.tableView.beginUpdates()
            let indexPaths = [ self.addItemRowIndexPath() ]
            if hideAddItemRow {
                self.logger?.logDebug(message: String(format: "[%@(%@)] Removing 'add ingredient' row from table view for search.", instanceType(self), self.crudName))
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            } else {
                self.logger?.logDebug(message: String(format: "[%@(%@)] Adding 'add ingredient' row to table view after search ended.", instanceType(self), self.crudName))
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
            self.tableView.endUpdates()
        }
    }

}

// MARK: UITextFieldDelegate
extension CrudViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) {
            setTableView(toHideAddItemRow: true)
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) {
            setTableView(toHideAddItemRow: false)
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetSearch()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let startingText = textField.nonemptyText ?? ""
        logger?.logDebug(message: String(format: "[%@(%@)] Text before search term update: %@.", instanceType(self), self.crudName, startingText))

        let endingText = (startingText as NSString).replacingCharacters(in: range, with: string)
        logger?.logDebug(message: String(format: "[%@(%@)] New search term: %@.", instanceType(self), self.crudName, endingText))

        if endingText.characters.count == 0 {
            logger?.logDebug(message: String(format: "[%@(%@)] User cleared search term. Resetting.", instanceType(self), self.crudName))
            resetSearch()
            return true
        }

        let predicate = searchDelegate.crudViewController(crudViewController: self, predicateForSearchString: endingText)
        logger?.logDebug(message: String(format: "[%@(%@)] Received fetch request predicate %@.", instanceType(self), self.crudName, predicate))

        var predicates = [ predicate ]
        if let original = originalFetchRequestPredicate {
            predicates.append(original)
        }

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        logger?.logDebug(message: String(format: "[%@(%@)] Searching with compound predicate %@.", instanceType(self), self.crudName, compoundPredicate))

        fetchedResultsController.fetchRequest.predicate = compoundPredicate

        reloadData()
        return true
    }

}

// MARK: NSFetchedResultsControllerDelegate
extension CrudViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger?.logDebug(message: String(format: "[%@(%@)] controller is about to update... clearing out table updates dictionary.", instanceType(self), self.crudName))
        tableUpdates = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        logger?.logVerbose(message: String(format: "[%@(%@)] changed object: %@", instanceType(self), self.crudName, String(describing: anObject)))
        logger?.logDebug(message: String(format: "[%@(%@)] Parsing change: %@ object: %@ with context: %@; indexPath: %@; newIndexPath: %@", instanceType(self), self.crudName, name(forFetchedResultsChangeType: type), instanceType(anObject as! NSObject), (anObject as! NSManagedObject).managedObjectContext!, String(describing: indexPath), String(describing: newIndexPath)))
        update(indexPath: indexPath, for: type, newIndexPath: newIndexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger?.logDebug(message: String(format: "[%@(%@)] controller <%@> finished updates", instanceType(self), self.crudName, controller))
        DispatchQueue.main.async {
            if let updates = self.tableUpdates {
                self.tableUpdates = nil
                self.logger?.logDebug(message: String(format: "[%@(%@)] Executing table updates.", instanceType(self), self.crudName))
                self.execute(tableUpdates: updates)
            }
        }
    }

}

// MARK: UITableViewDataSource
extension CrudViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.crudName)
            logger?.logWarning(message: message)
            return 0
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.crudName)
            logger?.logWarning(message: message)
            return 0
        }
        var rows = sections[section].numberOfObjects
        logger?.logVerbose(message: String(format: "[%@(%@)] Fetched results controller has %i objects.", instanceType(self), self.crudName, rows))
        if tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) && !hideAddItemRow && section == 0 {
            logger?.logVerbose(message: String(format: "[%@(%@)] Including 'Add object' cell in row count.", instanceType(self), self.crudName))
            rows += 1 // add one row for the "add object" row
        }
        logger?.logDebug(message: String(format: "[%@(%@)] Reporting %i rows in section %i", instanceType(self), self.crudName, rows, section))
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "AddObjectCell")
            cell.textLabel?.text = "Create new \(fetchedResultsController.fetchRequest.entityName!)"
            cell.textLabel?.font = .header
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.allowsDefaultTighteningForTruncation = true
            cell.accessoryView = UIImageView(image: UIImage(named: "add"))
            cell.selectionStyle = .none
            return cell
        }

        let object = fetchedResultsController.object(at: indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        tableViewDelegate.crudViewController(crudViewController: self, configure: cell, forObject: object)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return false
        }

        return tableViewDelegate.crudViewController(crudViewController: self, canEdit: fetchedResultsController.object(at: indexPath))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return nil
        }

        if !tableViewDelegate.crudViewController(crudViewController: self, canEdit: fetchedResultsController.object(at: indexPath)) {
            return nil
        }

        return tableViewDelegate.crudViewController(crudViewController: self, editActionsFor: tableView)
    }
    
}

// MARK: UITableViewDelegate
extension CrudViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger?.logDebug(message: String(format: "[%@(%@)] Table view row selected at %@", instanceType(self), self.crudName, String(reflecting: indexPath)))

        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            logger?.logDebug(message: String(format: "[%@(%@)] Add object row selected.", instanceType(self), self.crudName))

            crudDelegate.crudViewControllerWantsToCreateObject(crudViewController: self)
            return
        }

        searchField.resignFirstResponder()

        let object = fetchedResultsController.object(at: indexPath)

        logger?.logDebug(message: String(format: "[%@(%@)]User selected object: %@", instanceType(self), self.crudName, object as! NSManagedObject))

        tableViewDelegate.crudViewController(crudViewController: self, selected: object)
    }
    
}
