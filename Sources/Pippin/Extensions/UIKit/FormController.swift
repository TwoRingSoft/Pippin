//
//  FormController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/11/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

public class FormController: NSObject {

    fileprivate var inputViews: [UIView]!
    fileprivate var oldTextFieldDelegates: [UITextField: UITextFieldDelegate?] = [:]
    fileprivate var oldTextViewDelegates: [UITextView: UITextViewDelegate?] = [:]
    fileprivate weak var currentInputView: UIView?

    private weak var tableView: UITableView?
    private var originalContentInset: UIEdgeInsets?
    private var originalContentOffset: CGPoint?

    private var receivedDelegateCallback = false
    private var notification: Notification?
    private var notificationObservers = [AnyObject]()

    private var logger: Logger?

    /**
     Construct a `FormController` to manage traversing the items in `inputViews`.
     Use this constructor if you want to manage other aspects of the input fields
     like decoration or keeping visible.
     - Parameters:
         - inputViews: the array of form input fields to manage
         - logger: optional instance conforming to `Logger`
     */
    public init(inputViews: [UIView], logger: Logger? = nil) {
        super.init()
        self.inputViews = inputViews
        self.logger = logger
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
        - logger: optional instance conforming to `Logger`
     */
    public init(inputViews: [UIView], in tableView: UITableView, logger: Logger? = nil) {
        super.init()
        self.inputViews = inputViews
        self.tableView = tableView
        self.logger = logger
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
        let nextIdx = inputViews.index(of: currentInputView!)! + 1
        let nextField = inputViews[nextIdx]
        logger?.logDebug(message: String(format: "[%@] nextInputView: %@;", instanceType(self), String(describing: nextField), String(reflecting: nextField)))
        if !nextField.becomeFirstResponder() {
            guard let currentInputView = currentInputView else {
                fatalError("no current input view")
            }
            if !currentInputView.resignFirstResponder() && !currentInputView.endEditing(true) {
                fatalError("could not end editing in input field")
            } else {
                nextField.becomeFirstResponder()
            }
        }
    }

    func previousTextField() {
        let previousIdx = inputViews.index(of: currentInputView!)! - 1
        let previousField = inputViews[previousIdx]
        logger?.logDebug(message: String(format: "[%@] previousTextField: %@;", instanceType(self), String(describing: previousField), String(reflecting: previousField)))
        if !previousField.becomeFirstResponder() {
            guard let currentInputView = currentInputView else {
                fatalError("no current input view")
            }
            if !currentInputView.resignFirstResponder() && !currentInputView.endEditing(true) {
                fatalError("could not end editing in input field")
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
        if let idx = inputViews.index(of: view) {
            previousButton.isEnabled = idx > 0
        } else {
            previousButton.isEnabled = false
        }
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextInputView))
        if let idx = inputViews.index(of: view) {
            nextButton.isEnabled = idx < inputViews.count - 1
        } else {
            nextButton.isEnabled = false
        }

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12

        let toolbar = UIToolbar(frame: .zero)
        toolbar.items = [
            space,
            previousButton,
            space,
            nextButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton,
            space,
        ]

        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        view.backgroundColor = .lightGray
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
        guard let tableView = self.tableView else { return }
        guard let currentInputView = self.currentInputView else { return }

        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        guard let targetCell = self.visibleCell(forInputView: currentInputView) else { return }
        guard let targetCellIndexPath = tableView.indexPath(for: targetCell) else { return }

        let unhide: ((Bool) -> ()) = { completed in
            let targetCellIsInvisible = self.invisibleIndexPaths(tableView: tableView).contains(targetCellIndexPath)
            let targetCellIsCoveredByKeyboard = !self.visibleCells(notUnder: keyboardFrame).contains(targetCell)
            if !targetCellIsInvisible && !targetCellIsCoveredByKeyboard {
                // don't need to unhide the target cell
                return
            }

            if let indexPath = tableView.indexPath(for: targetCell) {
                if let superview = currentInputView.superview {
                    let a = currentInputView.center.y / superview.bounds.height
                    var position: UITableViewScrollPosition
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

        if self.originalContentInset == nil {
            guard let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
            guard let curveRawValue = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }

            self.originalContentInset = tableView.contentInset
            let curveOption = UIViewAnimationOptions(rawValue: curveRawValue)
            UIView.animate(withDuration: duration, delay: 0, options: curveOption, animations: {
                tableView.contentInset = tableView.contentInset.inset(bottomDelta: keyboardFrame.height).inset(bottomDelta: -49)
                tableView.scrollIndicatorInsets = tableView.contentInset.inset(bottomDelta: keyboardFrame.height)
            }, completion: unhide)
        } else {
            unhide(true)
        }
    }

    func handleKeyboardHide(notification: Notification) {
        guard let tableView = self.tableView else { return }
        guard let originalContentInset = self.originalContentInset else { return }

        guard let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let curveRawValue = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        let curveOption = UIViewAnimationOptions(rawValue: curveRawValue)

        self.originalContentInset = nil
        UIView.animate(withDuration: duration, delay: 0, options: curveOption, animations: {
            tableView.contentInset = originalContentInset
            tableView.scrollIndicatorInsets = originalContentInset
        })
    }

    func _init() {
        [ NSNotification.Name.UIKeyboardWillChangeFrame, NSNotification.Name.UIKeyboardWillHide ].forEach {
            let observer = NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main) { notification in
                switch notification.name {
                case NSNotification.Name.UIKeyboardWillChangeFrame:
                    self.logger?.logDebug(message: String(format: "[%@] UIKeyboardWillChangeFrame", instanceType(self)))
                    if self.receivedDelegateCallback {
                        self.receivedDelegateCallback = false
                        self.notification = nil
                        self.handleKeyboardDisplay(notification: notification)
                    } else {
                        self.notification = notification
                    }
                    break
                case NSNotification.Name.UIKeyboardWillHide:
                    self.logger?.logDebug(message: String(format: "[%@] UIKeyboardWillHide", instanceType(self)))
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
                if inputViews.index(of: textField)! < inputViews.count - 1 {
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
        logger?.logDebug(message: String(format: "[%@] textViewDidBeginEditing: %@", instanceType(self), textView))
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
        logger?.logDebug(message: String(format: "[%@] textViewDidEndEditing: %@", instanceType(self), textView))
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        logger?.logDebug(message: String(format: "[%@] textViewShouldEndEditing: %@", instanceType(self), textView))
        return true
    }

}

// MARK: UITextFieldDelegate
extension FormController: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        logger?.logDebug(message: String(format: "[%@] textFieldDidBeginEditing: %@", instanceType(self), textField))
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

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate, let delegateResponse = unwrappedDelegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return delegateResponse
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let idx = inputViews.index(of: textField)!
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
