//
//  FormController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/11/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import Pippin
import PippinLibrary
import UIKit

/**
 Provided as a `UIAppearanceContainer` specifically to style the contents of the
 input views created by the `FormController`.
 */
public class FormControllerInputAccessoryToolbar: UIToolbar {}

public class FormController: NSObject {

    fileprivate var inputViews: [UIView]!
    fileprivate var oldTextFieldDelegates: [UITextField: UITextFieldDelegate?] = [:]
    fileprivate var oldTextViewDelegates: [UITextView: UITextViewDelegate?] = [:]
    @objc public weak var currentInputView: UIView?

    private var allowTraversal: Bool = true
    private weak var tableView: UITableView?
    private weak var scrollView: UIScrollView?
    private var originalContentInset: UIEdgeInsets?
    private var originalContentOffset: CGPoint?
    private var insetScrollViewContentForAccessoryView: Bool = false

    private var receivedDelegateCallback = false
    private var notification: Notification?
    private var notificationObservers = [AnyObject]()

    private var environment: Environment?

    /**
     Construct a `FormController` to manage traversing the items in `inputViews`.
     Use this constructor if you want to manage other aspects of the input fields
     like decoration or keeping visible.
     - Parameters:
         - inputViews: the array of form input fields to manage
         - environment: optional instance of an app's environment
     */
    @objc public init(inputViews: [UIView], environment: Environment?) {
        super.init()
        self.inputViews = inputViews
        self.environment = environment
        _init()
    }

    /**
     Construct a `FormController` to manage traversing the items in `inputViews`
     with the table view that contains them to keep the current input field from
     being covered by the keyboard.
     - Parameters:
        - inputViews: the array of form input fields to iterate through, in order
        - tableView: tableView with cells containing input fields, for keyboard
            avoidance
        - allowTraversal: if `true`, provide Next/Prev buttons to navigate to
            other text fields managed by the `FormController`; if `false`, only
            provide the Done button to dismiss an input view
        - environment: optional instance of an app's environment
     */
    @objc public init(inputViews: [UIView], in tableView: UITableView, allowTraversal: Bool = true, environment: Environment?) {
        super.init()
        self.inputViews = inputViews
        self.tableView = tableView
        self.environment = environment
        self.allowTraversal = allowTraversal
        _init()
    }

    @objc public init(inputViews: [UIView], inScrollView scrollView: UIScrollView, environment: Environment?) {
        super.init()
        self.inputViews = inputViews
        self.scrollView = scrollView
        self.environment = environment
        _init()
    }

    deinit {
        deinitialize()
    }

}

// MARK: Public
public extension FormController {

    func resignResponders() {
        for inputView in inputViews {
            inputView.resignFirstResponder()
        }
    }

    func deinitialize() {
        currentInputView = nil

        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()

        oldTextViewDelegates.forEach { entry in
            let (textView, delegate) = entry
            textView.delegate = delegate
        }
        oldTextViewDelegates.removeAll()

        oldTextFieldDelegates.forEach { entry in
            let (textField, delegate) = entry
            textField.delegate = delegate
        }
        oldTextFieldDelegates.removeAll()
    }

}

// MARK: Actions
@objc private extension FormController {

    func donePressed() {
        resignResponders()
    }

    func nextInputView() {
        let logger = environment?.logger
        guard let currentInputView = currentInputView else {
            logger?.logWarning(message: String(format: "[%@] No currentInputView during traversal.", instanceType(self)))
            return
        }
        guard let currentInputViewIndex = inputViews.firstIndex(of: currentInputView) else {
            logger?.logWarning(message: String(format: "[%@] currentInputView not found in inputViews: %@.", instanceType(self), String(describing: inputViews)))
            return
        }
        let nextIdx = currentInputViewIndex + 1
        let nextField = inputViews[nextIdx]
        logger?.logDebug(message: String(format: "[%@] nextInputView: %@;", instanceType(self), String(describing: nextField), String(reflecting: nextField)))
        if !nextField.becomeFirstResponder() {
            if !currentInputView.resignFirstResponder() && !currentInputView.endEditing(true) {
                logger?.logWarning(message: String(format: "[%@] could not end editing in input field: %@", instanceType(self), String(describing: currentInputView)))
            } else {
                nextField.becomeFirstResponder()
            }
        }
    }

    func previousTextField() {
        let logger = environment?.logger
        guard let currentInputView = currentInputView else {
            logger?.logWarning(message: String(format: "[%@] No currentInputView during traversal.", instanceType(self)))
            return
        }
        guard let currentInputViewIndex = inputViews.firstIndex(of: currentInputView) else {
            logger?.logWarning(message: String(format: "[%@] currentInputView not found in inputViews: %@.", instanceType(self), String(describing: inputViews)))
            return
        }
        let previousIdx = currentInputViewIndex - 1
        let previousField = inputViews[previousIdx]
        logger?.logDebug(message: String(format: "[%@] previousTextField: %@;", instanceType(self), String(describing: previousField), String(reflecting: previousField)))
        if !previousField.becomeFirstResponder() {
            if !currentInputView.resignFirstResponder() && !currentInputView.endEditing(true) {
                logger?.logWarning(message: String(format: "[%@] could not end editing in input field: %@", instanceType(self), String(describing: currentInputView)))
            } else {
                previousField.becomeFirstResponder()
            }
        }
    }
}

// MARK: Private
private extension FormController {

    func accessoryViewForInputView(view: UIView) -> UIView {
        let previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(previousTextField))
        if let idx = inputViews.firstIndex(of: view) {
            previousButton.isEnabled = idx > 0
        } else {
            previousButton.isEnabled = false
        }
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextInputView))
        if let idx = inputViews.firstIndex(of: view) {
            nextButton.isEnabled = idx < inputViews.count - 1
        } else {
            nextButton.isEnabled = false
        }

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12

        let toolbar = FormControllerInputAccessoryToolbar(frame: .zero)
        var items = [UIBarButtonItem]()
        if allowTraversal && inputViews.count > 0 {
            items.append(contentsOf: [
                space,
                previousButton,
                space,
                nextButton
            ])
        }
        items.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton,
            space
        ])
        toolbar.items = items

        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        view.addSubview(toolbar)
        toolbar.edgeAnchors == view.edgeAnchors
        return view
    }

    func inputView(forCell cell: UITableViewCell) -> UIView? {
        guard let tableView = tableView else { return nil }
        guard let window = UIApplication.shared.keyWindow else { return nil }
        let absoluteCellFrame = window.convert(cell.frame, from: tableView)
        return inputViews.filter { view in
            let absoluteInputViewFrame = window.convert(view.frame, from: view.superview)
            return absoluteCellFrame.intersects(absoluteInputViewFrame)
        }.first
    }

    func visibleCell(forInputView inputView: UIView) -> UITableViewCell? {
        guard let tableView = tableView else { return nil }
        guard let window = UIApplication.shared.keyWindow else { return nil }
        let absoluteInputViewFrame = window.convert(inputView.frame, from: inputView.superview)
        return tableView.visibleCells.filter { cell in
            let absoluteCellFrame = window.convert(cell.frame, from: tableView)
            return absoluteCellFrame.intersects(absoluteInputViewFrame)
        }.first
    }

    func visibleCells(notUnder keyboardFrame: CGRect) -> [UITableViewCell] {
        guard let tableView = tableView else { return [] }
        return tableView.visibleCells.filter { cell in
            guard let inputView = self.inputView(forCell: cell) else { return false }
            guard let absoluteInputViewFrame = UIApplication.shared.keyWindow?.convert(inputView.frame, from: inputView.superview) else { return false }

            var keyboardIntersectionFrame = keyboardFrame
            if let accessoryView = inputView.inputAccessoryView {
                keyboardIntersectionFrame.size.height += accessoryView.bounds.height
                keyboardIntersectionFrame.origin.y -= accessoryView.bounds.height
            }
            return !absoluteInputViewFrame.intersects(keyboardIntersectionFrame)
        }
    }

    func invisibleIndexPaths(tableView: UITableView) -> [IndexPath] {
        let rows = tableView.numberOfRows(inSection: 0)
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return [] }
        if visibleIndexPaths.count == rows { return [] }

        let allIndexPaths = (0 ..< rows).map { row in
            return IndexPath(row: row, section: 0)
        }
        let invisibleIndexPaths = allIndexPaths.filter { indexPath in
            return !visibleIndexPaths.contains(indexPath)
        }
        return invisibleIndexPaths
    }

    func handleKeyboardDisplay(notification: Notification) {
        guard let currentInputView = self.currentInputView else { return }
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let unhide: ((Bool) -> ()) = { completed in
            if let scrollView = self.scrollView, !self.insetScrollViewContentForAccessoryView, let inputAccessoryView = currentInputView.inputAccessoryView {
                self.insetScrollViewContentForAccessoryView = true
                scrollView.contentInset = scrollView.contentInset.inset(bottomDelta: (inputAccessoryView.bounds.height + 12))
            } else {
                guard let tableView = self.tableView else { return }
                guard let targetCell = self.visibleCell(forInputView: currentInputView) else { return }
                guard let targetCellIndexPath = tableView.indexPath(for: targetCell) else { return }
                
                let targetCellIsInvisible = self.invisibleIndexPaths(tableView: tableView).contains(targetCellIndexPath)
                let targetCellIsCoveredByKeyboard = !self.visibleCells(notUnder: keyboardFrame).contains(targetCell)
                if !targetCellIsInvisible && !targetCellIsCoveredByKeyboard {
                    // don't need to unhide the target cell
                    return
                }
                
                if let indexPath = tableView.indexPath(for: targetCell) {
                    if let superview = currentInputView.superview {
                        let a = currentInputView.center.y / superview.bounds.height
                        var position: UITableView.ScrollPosition
                        if a < 0.34 {
                            position = .top
                        } else if a < 0.67 {
                            position = .middle
                        } else {
                            position = .bottom
                        }
                        tableView.scrollToRow(at: indexPath, at: position, animated: true)
                    } else {
                        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                    }
                }
            }
        }

        if self.originalContentInset == nil {
            guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
            guard let curveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
            guard let scrollView = self.tableView ?? self.scrollView else { return }
            self.originalContentInset = scrollView.contentInset
            let curveOption = UIView.AnimationOptions(rawValue: curveRawValue)
            UIView.animate(withDuration: duration, delay: 0, options: curveOption, animations: {
                var insets = scrollView.contentInset
                insets.bottom = keyboardFrame.height - 49
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = scrollView.contentInset.inset(bottomDelta: keyboardFrame.height)
            }, completion: unhide)
        } else {
            unhide(true)
        }
    }

    func handleKeyboardHide(notification: Notification) {
        guard let originalContentInset = self.originalContentInset else { return }
        self.originalContentInset = nil
        
        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let curveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        let curveOption = UIView.AnimationOptions(rawValue: curveRawValue)

        if let tableView = tableView {
            UIView.animate(withDuration: duration, delay: 0, options: curveOption, animations: {
                tableView.contentInset = originalContentInset
                tableView.scrollIndicatorInsets = originalContentInset
            })
        } else if let scrollView = scrollView {
            scrollView.contentInset = originalContentInset
            insetScrollViewContentForAccessoryView = false
        }
    }

    func _init() {
        [ UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardWillHideNotification ].forEach {
            let observer = NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main) { notification in
                let logger = self.environment?.logger
                switch notification.name {
                case UIResponder.keyboardWillChangeFrameNotification:
                    logger?.logDebug(message: String(format: "[%@] UIKeyboardWillChangeFrame", instanceType(self)))
                    if self.receivedDelegateCallback {
                        self.receivedDelegateCallback = false
                        self.notification = nil
                        self.handleKeyboardDisplay(notification: notification)
                    } else {
                        self.notification = notification
                    }
                    break
                case UIResponder.keyboardWillHideNotification:
                    logger?.logDebug(message: String(format: "[%@] UIKeyboardWillHide", instanceType(self)))
                    self.handleKeyboardHide(notification: notification)
                    break
                default: fatalError("Unexpected notification received")
                }
            }
            self.notificationObservers.append(observer)
        }

        for inputView in inputViews {
            if let textField = inputView as? UITextField {
                oldTextFieldDelegates[textField] = textField.delegate
                textField.delegate = self
                textField.inputAccessoryView = accessoryViewForInputView(view: textField)
                if inputViews.firstIndex(of: textField)! < inputViews.count - 1 {
                    textField.returnKeyType = .next
                } else {
                    textField.returnKeyType = .done
                }
            } else if let textView = inputView as? UITextView {
                oldTextViewDelegates[textView] = textView.delegate
                textView.delegate = self
                textView.inputAccessoryView = accessoryViewForInputView(view: textView)
            } else {
                fatalError("Unsupported responder type.")
            }
        }
    }

}

// MARK: UITextViewDelegate
extension FormController: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewDidBeginEditing: %@", instanceType(self), textView))
        currentInputView = textView

        if let notification = self.notification {
            self.notification = nil
            self.receivedDelegateCallback = false
            handleKeyboardDisplay(notification: notification)
        } else {
            self.receivedDelegateCallback = true
        }

        if let delegate = oldTextViewDelegates[textView], let unwrappedDelegate = delegate {
            unwrappedDelegate.textViewDidBeginEditing?(textView)
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewDidEndEditing: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates[textView], let unwrappedDelegate = delegate {
            unwrappedDelegate.textViewDidEndEditing?(textView)
        }
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewShouldEndEditing: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates[textView], let unwrappedDelegate = delegate, let result = unwrappedDelegate.textViewShouldEndEditing?(textView) {
            return result
        } else {
            return true
        }
    }

    public func textViewDidChange(_ textView: UITextView) {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewDidChange: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates[textView], let unwrappedDelegate = delegate {
            unwrappedDelegate.textViewDidChange?(textView)
        }
    }

}

// MARK: UITextFieldDelegate
extension FormController: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        environment?.logger?.logDebug(message: String(format: "[%@] textFieldDidBeginEditing: %@", instanceType(self), textField))
        currentInputView = textField

        if let notification = self.notification {
            self.notification = nil
            self.receivedDelegateCallback = false
            handleKeyboardDisplay(notification: notification)
        } else {
            self.receivedDelegateCallback = true
        }

        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate {
            unwrappedDelegate.textFieldDidBeginEditing?(textField)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        environment?.logger?.logDebug(message: String(format: "[%@] textFieldDidEndEditing: %@", instanceType(self), textField))

        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate {
            unwrappedDelegate.textFieldDidEndEditing?(textField)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate, let delegateResponse = unwrappedDelegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return delegateResponse
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let idx = inputViews.firstIndex(of: textField)!
        if idx == inputViews.count - 1 {
            resignResponders()
        } else {
            nextInputView()
        }

        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate, let delegateResponse = unwrappedDelegate.textFieldShouldReturn?(textField) {
            return delegateResponse
        }

        return true
    }

}
