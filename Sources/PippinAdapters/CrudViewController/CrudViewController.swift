//
//  CRUDViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import CoreData
import Pippin
import PippinLibrary
import UIKit

public struct EmptyStateDecorator {
    var tableView: UITableView
    var emptyView: UIView
    func toggle(emptyState: Bool, animated: Bool) {
        let animations = {
            self.emptyView.alpha = emptyState ? 1 : 0
            self.tableView.alpha = emptyState ? 0 : 1
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: animations)
        } else {
            animations()
        }
    }
}

public class CRUDSearchContainer: UIView {}

/// A subclass of `UIViewController` that presents UI to facility CRUD operations over a backing data model.
@available(iOS 11.0, *) public class CRUDViewController: UIViewController {

    private let entityCellReuseIdentifier = "CRUDViewControllerCell"
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var searchField: UITextField?
    private var searchContainer: CRUDSearchContainer?
    private var searchCancelButton: UIButton?
    private var cancelButtonBlurView: UIVisualEffectView?
    private var searchCancelButtonWidthConstraint: NSLayoutConstraint?
    private var searchCancelButtonLeadingConstraint: NSLayoutConstraint?
    private var hideAddItemRowForSearch = false
    private var crudName: String
    private var originalFetchRequestPredicate: NSPredicate?
    private var emptyView: UIView?
    typealias UpdateTable = [NSFetchedResultsChangeType: [IndexPath]]
    private var tableUpdates: UpdateTable?
    private var configuration: CRUDViewControllerConfiguration
    private var environment: Environment?

    public init(configuration: CRUDViewControllerConfiguration, environment: Environment? = nil) {
        self.environment = environment
        self.configuration = configuration
        self.crudName = configuration.name ?? configuration.fetchRequest.entityName!
        super.init(nibName: nil, bundle: nil)
        setUpFetchedResultsController(withFetchRequest: configuration.fetchRequest)
        setUpUI()
        setLookAndFeel()
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Initialized CRUDViewController with context %@.", instanceType(self), crudName, configuration.context))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
@available(iOS 11.0, *) public extension CRUDViewController {

    func reloadData() {
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Reloading data using performFetch on NSFetchedResultsController: %@ and rows using reloadData on UITableView: %@.", instanceType(self), crudName, fetchedResultsController, tableView))
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
                toggle(emptyState: true, animated: true)
            } else {
                toggle(emptyState: false, animated: true)
                tableView.reloadData()
            }
        } catch {
            let message = String(format: "[%@(%@)] Could not perform a new fetch on NSFetchedResultsController: %@.", instanceType(self), crudName, fetchedResultsController)
            environment?.logger?.logError(message: message, error: error)
        }
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
@available(iOS 11.0, *) @objc extension CRUDViewController {

    func cancelSearch() {
        resetSearch()
        searchField?.text = nil
        searchField?.resignFirstResponder()
    }

}

// MARK: Private
@available(iOS 11.0, *) private extension CRUDViewController {
    
    func shouldShowAddItemCell() -> Bool {
        return configuration.tableViewDelegate?.crudViewControllerShouldShowAddItemRow?(crudViewController: self) ?? (configuration.mode == .editor)
    }
    
    func canEditRow(atIndexPath indexPath: IndexPath) -> Bool {
        return configuration.tableViewDelegate?.crudViewController?(crudViewController: self, canEdit: fetchedResultsController.object(at: indexPath)) ?? (configuration.mode == .editor)
    }

    func numberOfEntities() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func toggle(emptyState: Bool, animated: Bool) {
        guard let emptyView = emptyView else { return }
        let animations = {
            emptyView.alpha = emptyState ? 1 : 0
            self.tableView.alpha = emptyState ? 0 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations)
        } else {
            animations()
        }
    }
    
    func shouldShowSearch() -> Bool {
        return configuration.searchDelegate?.crudViewControllerShouldEnableSearch(crudViewController: self) ?? false
    }

    func setLookAndFeel() {
        if shouldShowSearch(), let searchField = searchField, let searchContainer = searchContainer, let searchCancelButton = searchCancelButton {
            configuration.themeDelegate?.crudViewController?(crudViewController: self, theme: searchField, cancelButton: searchCancelButton)
            if let shouldBlur = configuration.themeDelegate?.crudViewControllerShouldBlurSearchControls?(crudViewController: self), shouldBlur {
                let fieldBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
                cancelButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
                guard let cancelButtonBlurView = cancelButtonBlurView else { return }
                cancelButtonBlurView.alpha = 0
                [ fieldBlurView, cancelButtonBlurView ].forEach {
                    self.view.insertSubview($0, belowSubview: searchContainer)
                }
                fieldBlurView.edgeAnchors == searchField.edgeAnchors
                cancelButtonBlurView.edgeAnchors == searchCancelButton.edgeAnchors
            }
        }
    }

    func resetSearch() {
        fetchedResultsController.fetchRequest.predicate = originalFetchRequestPredicate
        reloadData()
    }

    func setUpFetchedResultsController(withFetchRequest fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: configuration.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        let notifications: [Notification.Name] = [
            .NSManagedObjectContextDidSave,
            .NSManagedObjectContextWillSave,
            .NSManagedObjectContextObjectsDidChange
        ]

        notifications.forEach {
            NotificationCenter.default.addObserver(forName: $0, object: nil, queue: nil) { [weak self] (note) in
                guard let sself = self else { return }
                sself.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Received NSManagedObjectContext notification: %@", instanceType(sself), sself.crudName, String(describing: note)))
            }
        }

        originalFetchRequestPredicate = fetchRequest.predicate
        fetchedResultsController.delegate = self
        reloadData()
    }

    func setUpUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        if let insets = configuration.themeDelegate?.crudViewControllerTableViewContentInsets?(crudViewController: self) {
            tableView.contentInset = insets
            tableView.contentOffset = CGPoint.zero.offset(yDelta: -insets.top)
        }
        if let klass = configuration.tableViewDelegate?.crudViewControllerCellClassToRegister?(crudViewController: self) {
            tableView.register(klass, forCellReuseIdentifier: entityCellReuseIdentifier)
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: entityCellReuseIdentifier)
        }
        view.addSubview(tableView)

        if shouldShowSearch() {
            searchField = UITextField.textField(withPlaceholder: "Search")
            guard let searchField = searchField else { return }
            searchField.delegate = self
            searchField.clearButtonMode = .whileEditing
            searchField.rightViewMode = .always

            searchCancelButton = UIButton(frame: .zero)
            guard let searchCancelButton = searchCancelButton else { return }
            searchCancelButton.configure(title: "Cancel", target: self, selector: #selector(cancelSearch))
            searchCancelButton.alpha = 0

            searchContainer = CRUDSearchContainer(frame: .zero)
            guard let searchContainer = searchContainer else { return }
            [ searchField, searchCancelButton ].forEach { searchContainer.addSubview($0) }
            searchField.leadingAnchor == searchContainer.leadingAnchor
            searchField.heightAnchor == 30
            searchField.verticalAnchors == searchContainer.verticalAnchors

            searchCancelButton.verticalAnchors == searchField.verticalAnchors
            searchCancelButtonLeadingConstraint = searchCancelButton.leadingAnchor == searchField.trailingAnchor
            searchCancelButton.trailingAnchor == searchContainer.trailingAnchor
            searchCancelButtonWidthConstraint = searchCancelButton.widthAnchor == 0

            view.addSubview(searchContainer)

            searchContainer.topAnchor == view.topAnchor + CGFloat.verticalMargin
            searchContainer.horizontalAnchors == view.horizontalAnchors + CGFloat.horizontalMargin

            tableView.topAnchor == searchContainer.bottomAnchor + CGFloat.verticalMargin
            tableView.horizontalAnchors == view.horizontalAnchors
            tableView.bottomAnchor == view.bottomAnchor
        } else {
            tableView.fillSuperview()
        }

        if let emptyView = configuration.themeDelegate?.crudViewControllerEmptyStateView?(crudViewController: self) {
            self.emptyView = emptyView
            view.addSubview(emptyView)
            emptyView.edgeAnchors == view.edgeAnchors
            self.toggle(emptyState: self.numberOfEntities() == 0, animated: false)
        }
    }

    func addItemRowIndexPath() -> IndexPath {
        return IndexPath(row: fetchedResultsController.fetchedObjects!.count, section: 0)
    }
    
    func sectionContainsAddItemRow(section: Int) -> Bool {
        return section == 0
    }

    func indexPathPointsToAddObjectRow(indexPath: IndexPath) -> Bool {
        if !shouldShowAddItemCell() || hideAddItemRowForSearch {
            return false
        }

        return indexPath.compare(addItemRowIndexPath()) == .orderedSame
    }

    func update(object: Any, indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Processing update: %@ at indexPath: %@; newIndexPath: %@.", instanceType(self), self.crudName, String(describing: type), String(describing: indexPath), String(describing: newIndexPath)))
        switch type {
        case .delete:
            guard let indexPath = indexPath else { break }
            addUpdate(type: type, indexPath: indexPath)
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            addUpdate(type: type, indexPath: newIndexPath)
        case .move:
            guard
                let indexPath = indexPath,
                let newIndexPath = newIndexPath
                else { break }

            addUpdate(type: .delete, indexPath: indexPath)
            addUpdate(type: .insert, indexPath: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { break }
            addUpdate(type: type, indexPath: indexPath)
        @unknown default:
            fatalError("New unexpected NSFetchedResultsChangeType: \(type)")
        }
    }

    func addUpdate(type: NSFetchedResultsChangeType, indexPath: IndexPath) {
        self.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Memoizing update: %@ at %@.", instanceType(self), self.crudName, String(describing: type), String(describing: indexPath)))
        if tableUpdates == nil {
            tableUpdates = [ type: [ indexPath ]]
            return
        }

        if tableUpdates![type] == nil {
            tableUpdates![type] = [ indexPath ]
            return
        }

        tableUpdates![type]!.append(indexPath)
    }

    func execute(tableUpdates: UpdateTable) {
        self.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Executing updates: %@.", instanceType(self), self.crudName, tableUpdates))
        tableView.performBatchUpdates({
            tableUpdates.forEach({ arg in
                let (updateType, indexPaths) = arg
                switch updateType {
                case .delete: tableView.deleteRows(at: indexPaths, with: .automatic)
                case .update: tableView.reloadRows(at: indexPaths, with: .automatic)
                case .insert: tableView.insertRows(at: indexPaths, with: .automatic)
                case .move: fatalError("Moving currently not supported.")
                @unknown default: fatalError("New unexpected NSFetchedResultsChangeType: \(updateType)")
                }
            })
        }) { finished in
            self.toggle(emptyState: self.numberOfEntities() == 0, animated: true)
        }
    }

    func setTableView(toHideAddItemRow hideAddItemRow: Bool) {
        guard
            let searchCancelButton = searchCancelButton,
            let searchCancelButtonWidthConstraint = searchCancelButtonWidthConstraint,
            let searchCancelButtonLeadingConstraint = searchCancelButtonLeadingConstraint
        else { return }

        DispatchQueue.main.async {
            let constraintAnimations = {
                searchCancelButtonWidthConstraint.constant = hideAddItemRow ? 60 : 0
                searchCancelButtonLeadingConstraint.constant = hideAddItemRow ? CGFloat.horizontalSpacing : 0
                self.view.layoutIfNeeded()
            }

            let alphaAnimations = {
                searchCancelButton.alpha = hideAddItemRow ? 1 : 0
                if let cancelButtonBlurView = self.cancelButtonBlurView {
                    cancelButtonBlurView.alpha = hideAddItemRow ? 1 : 0
                }
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

            self.hideAddItemRowForSearch = hideAddItemRow
            self.tableView.beginUpdates()
            let indexPaths = [ self.addItemRowIndexPath() ]
            if hideAddItemRow {
                self.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Removing 'add ingredient' row from table view for search.", instanceType(self), self.crudName))
                self.tableView.deleteRows(at: indexPaths, with: .fade)
            } else {
                self.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Adding 'add ingredient' row to table view after search ended.", instanceType(self), self.crudName))
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
            self.tableView.endUpdates()
        }
    }

}

// MARK: UITextFieldDelegate
@available(iOS 11.0, *) extension CRUDViewController: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if shouldShowAddItemCell() {
            setTableView(toHideAddItemRow: true)
        }
        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if shouldShowAddItemCell() {
            setTableView(toHideAddItemRow: false)
        }
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetSearch()
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            environment?.logger?.logInfo(message: String(format: "[%@(%@)] Ignoring Return key press in search.", instanceType(self), self.crudName))
            return false
        }

        let startingText = textField.nonemptyText ?? ""
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Text before search term update: %@.", instanceType(self), self.crudName, startingText))

        let endingText = (startingText as NSString).replacingCharacters(in: range, with: string)
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] New search term: %@.", instanceType(self), self.crudName, endingText))

        if endingText.count == 0 {
            environment?.logger?.logDebug(message: String(format: "[%@(%@)] User cleared search term. Resetting.", instanceType(self), self.crudName))
            resetSearch()
            return true
        }

        let predicate = configuration.searchDelegate?.crudViewController(crudViewController: self, predicateForSearchString: endingText) ?? NSPredicate(value: false)
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Received fetch request predicate %@.", instanceType(self), self.crudName, predicate))
        fetchedResultsController.fetchRequest.predicate = predicate
        reloadData()

        return true
    }

}

// MARK: NSFetchedResultsControllerDelegate
@available(iOS 11.0, *) extension CRUDViewController: NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] controller is about to update... clearing out table updates dictionary.", instanceType(self), self.crudName))
        tableUpdates = nil
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        environment?.logger?.logVerbose(message: String(format: "[%@(%@)] changed object: %@\nin context: %@", instanceType(self), self.crudName, String(describing: anObject), (anObject as! NSManagedObject).managedObjectContext!))
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Received change: %@ object: %@; indexPath: %@; newIndexPath: %@", instanceType(self), self.crudName, String(describing: type), String(describing: anObject), String(describing: indexPath), String(describing: newIndexPath)))
        update(object: anObject, indexPath: indexPath, for: type, newIndexPath: newIndexPath)
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] controller <%@> finished updates", instanceType(self), self.crudName, controller))
        DispatchQueue.main.async {
            if let updates = self.tableUpdates, updates.count > 0 {
                self.tableUpdates = nil
                self.environment?.logger?.logDebug(message: String(format: "[%@(%@)] Executing table updates.", instanceType(self), self.crudName))
                self.execute(tableUpdates: updates)
            }
        }
    }

}

// MARK: UITableViewDataSource
@available(iOS 11.0, *) extension CRUDViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.crudName)
            environment?.logger?.logWarning(message: message)
            return 0
        }
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.crudName)
            environment?.logger?.logWarning(message: message)
            return 0
        }
        var rows = sections[section].numberOfObjects
        environment?.logger?.logVerbose(message: String(format: "[%@(%@)] Fetched results controller has %i objects.", instanceType(self), self.crudName, rows))
        if shouldShowAddItemCell() && !hideAddItemRowForSearch && sectionContainsAddItemRow(section: section) {
            environment?.logger?.logVerbose(message: String(format: "[%@(%@)] Including 'Add object' cell in row count.", instanceType(self), self.crudName))
            rows += 1 // add one row for the "add object" row
        }
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Reporting %i rows in section %i", instanceType(self), self.crudName, rows, section))
        return rows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            let cell = TextAndAccessoryCell(style: .default, reuseIdentifier: textAndAccessoryCellReuseIdentifier)
            cell.label.text = String(format: "Create new %@", crudName)
            configuration.themeDelegate?.crudViewController?(crudViewController: self, themeAddItemCell: cell)
            cell.isAccessibilityElement = true
            return cell
        }

        let object = fetchedResultsController.object(at: indexPath)
        let lastObject = indexPath.row == tableView.numberOfRows(inSection: 0) - 1
        let cell = tableView.dequeueReusableCell(withIdentifier: entityCellReuseIdentifier, for: indexPath)
        configuration.tableViewDelegate?.crudViewController(crudViewController: self, configure: cell, forObject: object, lastObject: lastObject)
        return cell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard configuration.mode == .editor else {
            return false
        }
        
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return false
        }

        return canEditRow(atIndexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard configuration.mode == .editor else {
            return nil
        }
        
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return nil
        }

        if !canEditRow(atIndexPath: indexPath) {
            return nil
        }

        if let actions = configuration.tableViewDelegate?.crudViewController?(crudViewController: self, editActionsFor: indexPath) {
            return actions
        }

        var actions = [UITableViewRowAction]()
        if let otherActions = configuration.tableViewDelegate?.crudViewController?(crudViewController: self, otherEditActionsFor: indexPath) {
            actions.append(contentsOf: otherActions)
        }
        actions.append(contentsOf: [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
                self.configuration.crudDelegate?.crudViewController?(crudViewController: self, wantsToDelete: self.fetchedResultsController.object(at: indexPath))
            }),
            UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
                self.configuration.crudDelegate?.crudViewController?(crudViewController: self, wantsToUpdate: self.fetchedResultsController.object(at: indexPath))
            })
        ])
        return actions
    }
    
}

// MARK: UITableViewDelegate
@available(iOS 11.0, *) extension CRUDViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        environment?.logger?.logDebug(message: String(format: "[%@(%@)] Table view row selected at %@", instanceType(self), self.crudName, String(reflecting: indexPath)))

        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            environment?.logger?.logDebug(message: String(format: "[%@(%@)] Add object row selected.", instanceType(self), self.crudName))

            configuration.crudDelegate?.crudViewControllerWantsToCreateObject?(crudViewController: self)
            return
        }

        searchField?.resignFirstResponder()

        let object = fetchedResultsController.object(at: indexPath)

        environment?.logger?.logDebug(message: String(format: "[%@(%@)]User selected object: %@", instanceType(self), self.crudName, object as! NSManagedObject))

        configuration.crudDelegate?.crudViewController?(crudViewController: self, wantsToRead: object)
    }
    
}
