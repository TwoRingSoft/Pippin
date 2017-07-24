//
//  FetchedResultsSearchableListViewController.swift
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

protocol FetchedResultsSearchableListViewControllerDelegate {

    func cell(forObject object: NSFetchRequestResult, atIndexPath indexPath: IndexPath, inTableView tableView: UITableView, withReuseIdentifier reuseIdentifier: String) -> UITableViewCell
    func refresh(tableViewCell: UITableViewCell, forObject object: NSFetchRequestResult)

    func selected(object: NSFetchRequestResult)

    func addObject()
    func edit(object: NSFetchRequestResult)
    func delete(object: NSFetchRequestResult)

    func canEdit(object: NSFetchRequestResult) -> Bool

}

class FetchedResultsSearchableListViewController: UIViewController {

    fileprivate let cellReuseIdentifier = "FetchedResultsSearchableListViewControllerCell"
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    fileprivate var tableView = UITableView(frame: .zero, style: .plain)
    fileprivate var searchField: UITextField!
    fileprivate var searchCancelButton: UIButton!
    fileprivate var searchCancelButtonWidthConstraint: NSLayoutConstraint!
    fileprivate var searchCancelButtonLeadingConstraint: NSLayoutConstraint!
    fileprivate var context: NSManagedObjectContext!
    fileprivate var delegate: FetchedResultsSearchableListViewControllerDelegate!
    fileprivate var hideAddItemRow = false
    fileprivate var tableUpdates: [String: [IndexPath]]?

    init(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, delegate: FetchedResultsSearchableListViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.context = context
        setUpFetchedResultsController(withFetchRequest: fetchRequest)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
extension FetchedResultsSearchableListViewController {

    func reloadData() {
        DoughLogController.logDebug(message: String(format: "[%@(%@)] Reloading data using performFetch on NSFetchedResultsController: %@ and rows using reloadData on UITableView: %@.", instanceType(self), fetchedResultsController.fetchRequest.entityName!, fetchedResultsController, tableView))
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            let message = String(format: "[%@(%@)] Could not perform a new fetch on NSFetchedResultsController: %@.", instanceType(self), fetchedResultsController.fetchRequest.entityName!, fetchedResultsController)
            DoughLogController.logError(message: message, error: error)
        }
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    func deselectTableViewRow() {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: Actions
extension FetchedResultsSearchableListViewController {

    func addPressed() {
        delegate.addObject()
    }

    func cancelSearch() {
        resetSearch()
        searchField.text = nil
        searchField.resignFirstResponder()
    }

}

// MARK: Private
private extension FetchedResultsSearchableListViewController {

    func resetSearch() {
        fetchedResultsController.fetchRequest.predicate = nil
        reloadData()
    }

    func setUpFetchedResultsController(withFetchRequest fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.delegate = self
        reloadData()
    }

    func setUpUI() {
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self

        searchField = UITextField.textField(withPlaceholder: "Search")
        searchField.delegate = self
        searchField.clearButtonMode = .whileEditing
        searchField.rightViewMode = .always

        searchCancelButton = UIButton.button(withTitle: "Cancel")
        searchCancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
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

        NotificationController.subscribe(toNotificationName: .tabBarSelectedNewTab) { notification in
            self.cancelSearch()
        }
    }

    func addItemRowIndexPath() -> IndexPath {
        return IndexPath(row: fetchedResultsController.fetchedObjects!.count, section: 0)
    }

    func indexPathPointsToAddObjectRow(indexPath: IndexPath) -> Bool {
        if hideAddItemRow {
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
        if let inserts = tableUpdates[name(forFetchedResultsChangeType: .insert)] {
            DoughLogController.logDebug(message: String(format: "[%@(%@)] inserts: %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, inserts))
            performedUpdates = true
            tableView.beginUpdates()
            tableView.insertRows(at: inserts, with: .automatic)
        }

        if let deletes = tableUpdates[name(forFetchedResultsChangeType: .delete)] {
            DoughLogController.logDebug(message: String(format: "[%@(%@)] deletes: %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, deletes))
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
                DoughLogController.logDebug(message: String(format: "[%@(%@)] Removing 'add ingredient' row from table view for search.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            } else {
                DoughLogController.logDebug(message: String(format: "[%@(%@)] Adding 'add ingredient' row to table view after search ended.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
            self.tableView.endUpdates()
        }
    }

}

// MARK: UITextFieldDelegate
extension FetchedResultsSearchableListViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setTableView(toHideAddItemRow: true)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        setTableView(toHideAddItemRow: false)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetSearch()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let startingText = textField.text ?? ""
        let endingText = (startingText as NSString).replacingCharacters(in: range, with: string)

        if endingText.characters.count == 0 {
            resetSearch()
            return true
        }

        let term = [ "*", endingText.characters.map { String($0) }.joined(separator: "*"), "*"].joined()
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K LIKE[cd] %@", "name", term)
        reloadData()

        return true
    }

}

// MARK: NSFetchedResultsControllerDelegate
extension FetchedResultsSearchableListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DoughLogController.logDebug(message: String(format: "[%@(%@)] controller is about to update... clearing out table updates dictionary.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))
        tableUpdates = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        DoughLogController.logVerbose(message: String(format: "[%@(%@)] changed object: %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, String(describing: anObject)))
        DoughLogController.logDebug(message: String(format: "[%@(%@)] Parsing change: %@ object: %@ with context: %@; indexPath: %@; newIndexPath: %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, name(forFetchedResultsChangeType: type), instanceType(anObject as! NSObject), (anObject as! NSManagedObject).managedObjectContext!, String(describing: indexPath), String(describing: newIndexPath)))
        update(indexPath: indexPath, for: type, newIndexPath: newIndexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DoughLogController.logDebug(message: String(format: "[%@(%@)] controller <%@> finished updates", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, controller))
        DispatchQueue.main.async {
            if let updates = self.tableUpdates {
                DoughLogController.logDebug(message: String(format: "[%@(%@)] Executing table updates.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))
                self.execute(tableUpdates: updates)
            }
        }
    }

}

// MARK: UITableViewDataSource
extension FetchedResultsSearchableListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!)
            DoughLogController.logWarning(message: message)
            return 0
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!)
            DoughLogController.logWarning(message: message)
            return 0
        }
        var rows = sections[section].numberOfObjects
        DoughLogController.logVerbose(message: String(format: "[%@(%@)] Fetched results controller has %i objects.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, rows))
        if !hideAddItemRow && section == 0 {
            DoughLogController.logVerbose(message: String(format: "[%@(%@)] Including 'Add object' cell in row count.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))
            rows += 1 // add one row for the "add object" row
        }
        DoughLogController.logDebug(message: String(format: "[%@(%@)] Reporting %i rows in section %i", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, rows, section))
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
        let cell = self.delegate.cell(forObject: object, atIndexPath: indexPath, inTableView: tableView, withReuseIdentifier: cellReuseIdentifier)
        cell.textLabel?.font = .text
        cell.detailTextLabel?.font = .subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return false
        }

        return delegate.canEdit(object: fetchedResultsController.object(at: indexPath))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return nil
        }

        if !delegate.canEdit(object: fetchedResultsController.object(at: indexPath)) {
            return nil
        }

        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { _, indexPath in
                self.tableView.setEditing(false, animated: true)
                self.delegate.delete(object: self.fetchedResultsController.object(at: indexPath))
            }),
            UITableViewRowAction(style: .normal, title: "Edit", handler: { _, indexPath in
                self.tableView.setEditing(false, animated: true)
                self.delegate.edit(object: self.fetchedResultsController.object(at: indexPath))
            })
        ]
    }
    
}

// MARK: UITableViewDelegate
extension FetchedResultsSearchableListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DoughLogController.logDebug(message: String(format: "[%@(%@)] Table view row selected at %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, String(reflecting: indexPath)))

        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            DoughLogController.logDebug(message: String(format: "[%@(%@)] Add object row selected.", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!))

            delegate.addObject()
            return
        }

        searchField.resignFirstResponder()

        let object = fetchedResultsController.object(at: indexPath)

        DoughLogController.logDebug(message: String(format: "[%@(%@)]User selected object: %@", instanceType(self), self.fetchedResultsController.fetchRequest.entityName!, object as! NSManagedObject))

        delegate.selected(object: object)
    }
    
}
