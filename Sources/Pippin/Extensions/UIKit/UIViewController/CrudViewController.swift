//
//  CrudViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/12/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import CoreData
import UIKit

public enum ListViewControllerMode {
    case editor
    case picker
}

@available(iOS 11.0, *)
@objc public protocol CrudViewControllerThemeDelegate {
    @objc optional func crudViewController(crudViewController: CrudViewController, themeAddItemCell addItemCell: TextAndAccessoryCell)
    
    /// Sylize the search controls.
    ///
    /// - Parameters:
    ///   - crudViewController: the crud controller containing the search controls to style
    ///   - searchField: the text input for search
    ///   - cancelButton: the cancel button to end search
    @objc optional func crudViewController(crudViewController: CrudViewController, theme searchField: UITextField, cancelButton: UIButton)
    
    /// Ask the theme delegate if the search controls should be given blur backgrounds and vibrancy effects. Defaults to `false`.
    ///
    /// - Parameter crudViewController: the crud controller containing the search controls
    /// - Returns: `true` if the search field and cancel button should be blurred, `false` otherwise
    @objc optional func crudViewControllerShouldBlurSearchControls(crudViewController: CrudViewController) -> Bool
    
    @objc optional func crudViewControllerEmptyStateView(crudViewController: CrudViewController) -> UIView
}

@available(iOS 11.0, *)
public protocol CrudViewControllerCRUDDelegate {
    func crudViewControllerWantsToCreateObject(crudViewController: CrudViewController)
    func crudViewController(crudViewController: CrudViewController, wantsToUpdate object: NSFetchRequestResult)
    func crudViewController(crudViewController: CrudViewController, wantsToDelete object: NSFetchRequestResult)
}

@available(iOS 11.0, *)
public protocol CrudViewControllerUITableViewDelegate {
    func crudViewControllerCellClassToRegisterForReuseIdentifiers(crudViewController: CrudViewController) -> (String, AnyClass)?
    func crudViewControllerTableViewContentInsets(crudViewController: CrudViewController) -> UIEdgeInsets?
    func crudViewController(crudViewController: CrudViewController, configure cell: UITableViewCell, forObject object: NSFetchRequestResult, lastObject: Bool)
    func crudViewController(crudViewController: CrudViewController, selected object: NSFetchRequestResult)
    func crudViewController(crudViewController: CrudViewController, canEdit object: NSFetchRequestResult) -> Bool
    func crudViewController(crudViewController: CrudViewController, editActionsFor tableView: UITableView) -> [UITableViewRowAction]?
    func crudViewControllerShouldShowAddItemRow(crudViewController: CrudViewController) -> Bool
    func crudViewControllerShouldShowAllowMultipleSelections(crudViewController: CrudViewController) -> Bool
}

public class CrudSearchContainer: UIView {}

@available(iOS 11.0, *)
public protocol CrudViewControllerSearchDelegate {
    func crudViewControllerShouldEnableSearch(crudViewController: CrudViewController) -> Bool
    func crudViewController(crudViewController: CrudViewController, predicateForSearchString string: String) -> NSPredicate
}

@available(iOS 11.0, *)
public class CrudViewController: UIViewController {

    private let stockCellReuseIdentifier = "CrudViewControllerCell"
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var customCellReuseIdentifier: String?
    private var searchField: UITextField?
    private var searchContainer: CrudSearchContainer?
    private var searchCancelButton: UIButton?
    private var cancelButtonBlurView: UIVisualEffectView?
    private var searchCancelButtonWidthConstraint: NSLayoutConstraint?
    private var searchCancelButtonLeadingConstraint: NSLayoutConstraint?
    private var context: NSManagedObjectContext!
    private var crudDelegate: CrudViewControllerCRUDDelegate!
    private var tableViewDelegate: CrudViewControllerUITableViewDelegate!
    private var searchDelegate: CrudViewControllerSearchDelegate!
    private var themeDelegate: CrudViewControllerThemeDelegate?
    private var hideAddItemRow = false
    private var crudName: String!
    private var originalFetchRequestPredicate: NSPredicate?
    fileprivate var logger: Logger?
    private var emptyView: UIView?
    typealias UpdateTable = [NSFetchedResultsChangeType: [IndexPath]]
    private var tableUpdates: UpdateTable?

    public init(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, crudDelegate: CrudViewControllerCRUDDelegate, tableViewDelegate: CrudViewControllerUITableViewDelegate, searchDelegate: CrudViewControllerSearchDelegate, themeDelegate: CrudViewControllerThemeDelegate?, name: String? = nil, logger: Logger?) {
        super.init(nibName: nil, bundle: nil)
        self.logger = logger
        self.crudDelegate = crudDelegate
        self.tableViewDelegate = tableViewDelegate
        self.searchDelegate = searchDelegate
        self.themeDelegate = themeDelegate
        self.context = context
        self.crudName = name ?? fetchRequest.entityName!
        setUpFetchedResultsController(withFetchRequest: fetchRequest)
        setUpUI()
        setLookAndFeel()
        logger?.logDebug(message: String(format: "[%@(%@)] Initialized CrudViewController with context %@.", instanceType(self), crudName, context))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Public
@available(iOS 11.0, *)
public extension CrudViewController {

    func reloadData() {
        logger?.logDebug(message: String(format: "[%@(%@)] Reloading data using performFetch on NSFetchedResultsController: %@ and rows using reloadData on UITableView: %@.", instanceType(self), crudName, fetchedResultsController, tableView))
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
                toggle(emptyState: true, animated: true)
            } else {
                tableView.reloadData()
            }
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
@available(iOS 11.0, *)
@objc extension CrudViewController {

    func addPressed() {
        crudDelegate.crudViewControllerWantsToCreateObject(crudViewController: self)
    }

    func cancelSearch() {
        resetSearch()
        searchField?.text = nil
        searchField?.resignFirstResponder()
    }

}

// MARK: Private
@available(iOS 11.0, *)
private extension CrudViewController {

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

    func setLookAndFeel() {
        if searchDelegate.crudViewControllerShouldEnableSearch(crudViewController: self), let searchField = searchField, let searchContainer = searchContainer, let searchCancelButton = searchCancelButton {
            themeDelegate?.crudViewController?(crudViewController: self, theme: searchField, cancelButton: searchCancelButton)
            if let shouldBlur = themeDelegate?.crudViewControllerShouldBlurSearchControls?(crudViewController: self), shouldBlur {
                let fieldBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
                cancelButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
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
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        originalFetchRequestPredicate = fetchRequest.predicate
        fetchedResultsController.delegate = self
        reloadData()
    }

    func setUpUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = tableViewDelegate.crudViewControllerShouldShowAllowMultipleSelections(crudViewController: self)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        if let insets = tableViewDelegate?.crudViewControllerTableViewContentInsets(crudViewController: self) {
            tableView.contentInset = insets
            tableView.contentOffset = CGPoint.zero.offset(yDelta: -insets.top)
        }
        if let (reuseIdentifier, klass) = tableViewDelegate?.crudViewControllerCellClassToRegisterForReuseIdentifiers(crudViewController: self) {
            tableView.register(klass, forCellReuseIdentifier: reuseIdentifier)
            customCellReuseIdentifier = reuseIdentifier
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: stockCellReuseIdentifier)
        }
        view.addSubview(tableView)

        if searchDelegate.crudViewControllerShouldEnableSearch(crudViewController: self) {
            searchField = UITextField.textField(withPlaceholder: "Search")
            guard let searchField = searchField else { return }
            searchField.delegate = self
            searchField.clearButtonMode = .whileEditing
            searchField.rightViewMode = .always

            searchCancelButton = UIButton(frame: .zero)
            guard let searchCancelButton = searchCancelButton else { return }
            searchCancelButton.configure(title: "Cancel", target: self, selector: #selector(cancelSearch))
            searchCancelButton.alpha = 0

            searchContainer = CrudSearchContainer(frame: .zero)
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

        if let emptyView = themeDelegate?.crudViewControllerEmptyStateView?(crudViewController: self) {
            self.emptyView = emptyView
            view.addSubview(emptyView)
            emptyView.edgeAnchors == view.edgeAnchors
            self.toggle(emptyState: self.numberOfEntities() == 0, animated: false)
        }
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
        self.logger?.logDebug(message: String(format: "[%@(%@)] Processing update: %@ at %@%@.", instanceType(self), self.crudName, String(describing: type), String(describing: indexPath), newIndexPath != nil ? String(format: "to %@", String(describing: newIndexPath)) : ""))
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
        self.logger?.logDebug(message: String(format: "[%@(%@)] Memoizing update: %@ at %@.", instanceType(self), self.crudName, String(describing: type), String(describing: indexPath)))
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
        self.logger?.logDebug(message: String(format: "[%@(%@)] Executing updates: %@.", instanceType(self), self.crudName, tableUpdates))
        tableView.performBatchUpdates({
            tableUpdates.forEach({ arg in
                let (updateType, indexPaths) = arg
                switch updateType {
                case .delete: tableView.deleteRows(at: indexPaths, with: .automatic); break
                case .update: tableView.reloadRows(at: indexPaths, with: .automatic); break
                case .insert: tableView.insertRows(at: indexPaths, with: .automatic); break
                case .move: fatalError("Moving currently not supported.")
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
@available(iOS 11.0, *)
extension CrudViewController: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) {
            setTableView(toHideAddItemRow: true)
        }
        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if tableViewDelegate.crudViewControllerShouldShowAddItemRow(crudViewController: self) {
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
            logger?.logInfo(message: String(format: "[%@(%@)] Ignoring Return key press in search.", instanceType(self), self.crudName))
            return false
        }

        let startingText = textField.nonemptyText ?? ""
        logger?.logDebug(message: String(format: "[%@(%@)] Text before search term update: %@.", instanceType(self), self.crudName, startingText))

        let endingText = (startingText as NSString).replacingCharacters(in: range, with: string)
        logger?.logDebug(message: String(format: "[%@(%@)] New search term: %@.", instanceType(self), self.crudName, endingText))

        if endingText.count == 0 {
            logger?.logDebug(message: String(format: "[%@(%@)] User cleared search term. Resetting.", instanceType(self), self.crudName))
            resetSearch()
            return true
        }

        let predicate = searchDelegate.crudViewController(crudViewController: self, predicateForSearchString: endingText)
        logger?.logDebug(message: String(format: "[%@(%@)] Received fetch request predicate %@.", instanceType(self), self.crudName, predicate))
        fetchedResultsController.fetchRequest.predicate = predicate
        reloadData()

        return true
    }

}

// MARK: NSFetchedResultsControllerDelegate
@available(iOS 11.0, *)
extension CrudViewController: NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger?.logDebug(message: String(format: "[%@(%@)] controller is about to update... clearing out table updates dictionary.", instanceType(self), self.crudName))
        tableUpdates = nil
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        logger?.logVerbose(message: String(format: "[%@(%@)] changed object: %@\nin context: %@", instanceType(self), self.crudName, String(describing: anObject), (anObject as! NSManagedObject).managedObjectContext!))
        logger?.logDebug(message: String(format: "[%@(%@)] Received change: %@ object: %@; indexPath: %@; newIndexPath: %@", instanceType(self), self.crudName, String(describing: type), instanceType(anObject as! NSObject), String(describing: indexPath), String(describing: newIndexPath)))
        update(indexPath: indexPath, for: type, newIndexPath: newIndexPath)
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger?.logDebug(message: String(format: "[%@(%@)] controller <%@> finished updates", instanceType(self), self.crudName, controller))
        DispatchQueue.main.async {
            if let updates = self.tableUpdates, updates.count > 0 {
                self.tableUpdates = nil
                self.logger?.logDebug(message: String(format: "[%@(%@)] Executing table updates.", instanceType(self), self.crudName))
                self.execute(tableUpdates: updates)
            }
        }
    }

}

// MARK: UITableViewDataSource
@available(iOS 11.0, *)
extension CrudViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            let message = String(format: "[%@(%@)] Couldn't query fetched results controller for number of sections.", instanceType(self), self.crudName)
            logger?.logWarning(message: message)
            return 0
        }
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            let cell = TextAndAccessoryCell(style: .default, reuseIdentifier: textAndAccessoryCellReuseIdentifier)
            cell.label.text = String(format: "Create new %@", crudName)
            themeDelegate?.crudViewController?(crudViewController: self, themeAddItemCell: cell)
            cell.accessibilityLabel = textAndAccessoryCellReuseIdentifier
            cell.isAccessibilityElement = true
            return cell
        }

        let object = fetchedResultsController.object(at: indexPath)
        let lastObject = indexPath.row == tableView.numberOfRows(inSection: 0) - 1
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellReuseIdentifier ?? stockCellReuseIdentifier, for: indexPath)
        tableViewDelegate.crudViewController(crudViewController: self, configure: cell, forObject: object, lastObject: lastObject)
        return cell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            return false
        }

        return tableViewDelegate.crudViewController(crudViewController: self, canEdit: fetchedResultsController.object(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
@available(iOS 11.0, *)
extension CrudViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger?.logDebug(message: String(format: "[%@(%@)] Table view row selected at %@", instanceType(self), self.crudName, String(reflecting: indexPath)))

        if indexPathPointsToAddObjectRow(indexPath: indexPath) {
            logger?.logDebug(message: String(format: "[%@(%@)] Add object row selected.", instanceType(self), self.crudName))

            crudDelegate.crudViewControllerWantsToCreateObject(crudViewController: self)
            return
        }

        searchField?.resignFirstResponder()

        let object = fetchedResultsController.object(at: indexPath)

        logger?.logDebug(message: String(format: "[%@(%@)]User selected object: %@", instanceType(self), self.crudName, object as! NSManagedObject))

        tableViewDelegate.crudViewController(crudViewController: self, selected: object)
    }
    
}
