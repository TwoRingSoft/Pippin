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

public class FormControllerInputAccessoryView: UIView {
    var nextButton: UIBarButtonItem?
    var previousButton: UIBarButtonItem?

    init(nextButton: UIBarButtonItem?, previousButton: UIBarButtonItem?, frame: CGRect) {
        self.nextButton = nextButton
        self.previousButton = previousButton
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class FormController: NSObject {

    fileprivate let inputViews = NSPointerArray(options: .weakMemory)
    fileprivate var oldTextFieldDelegates = NSMapTable<UITextField, UITextFieldDelegate>(keyOptions: .weakMemory, valueOptions: .weakMemory)
    fileprivate var oldTextViewDelegates = NSMapTable<UITextView, UITextViewDelegate>(keyOptions: .weakMemory, valueOptions: .weakMemory)

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

//    private lazy var visualDebugWindow: UIWindow = {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue + 100)
//        window.rootViewController = UIViewController(nibName: nil, bundle: nil)
//        window.rootViewController?.view.layer.borderColor = UIColor.red.cgColor
//        window.rootViewController?.view.layer.borderWidth = 2
//        window.isHidden = false
//        window.isUserInteractionEnabled = false
//        return window
//    }()

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
        weakly(inputViews: inputViews)
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
        weakly(inputViews: inputViews)
        self.tableView = tableView
        self.environment = environment
        self.allowTraversal = allowTraversal
        _init()
    }

    @objc public init(inputViews: [UIView], inScrollView scrollView: UIScrollView, environment: Environment?) {
        super.init()
        weakly(inputViews: inputViews)
        self.scrollView = scrollView
        self.environment = environment
        _init()
    }

    func weakly(inputViews: [UIView]) {
        inputViews.forEach {
            self.inputViews.addPointer(Unmanaged.passUnretained($0).toOpaque())
        }
    }

    func resolvedInputViews() -> [UIView] {
        var views = [UIView]()
        inputViews.allObjects.forEach {
            guard let view = $0 as? UIView else { return }
            views.append(view)
        }
        return views
    }

    func resolvedTextFieldDelegates() -> [UITextField: UITextFieldDelegate] {
        var delegates = [UITextField: UITextFieldDelegate]()
        oldTextFieldDelegates.keyEnumerator().allObjects.forEach {
            guard let key = $0 as? UITextField else { return }
            delegates[key] = oldTextFieldDelegates.object(forKey: key)
        }
        return delegates
    }

    func resolvedTextViewDelegates() -> [UITextView: UITextViewDelegate] {
        var delegates = [UITextView: UITextViewDelegate]()
        oldTextViewDelegates.keyEnumerator().allObjects.forEach {
            guard let key = $0 as? UITextView else { return }
            delegates[key] = oldTextViewDelegates.object(forKey: key)
        }
        return delegates
    }

    deinit {
        deinitialize()
    }

}

// MARK: Public
public extension FormController {

    func resignResponders() {
        for inputView in resolvedInputViews() {
            inputView.resignFirstResponder()
        }
    }

    /// Reset any passed-through delegate relationships to direct references again, remove from containers and set any other references to nil.
    func deinitialize() {
        currentInputView = nil

        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()

        resolvedTextViewDelegates().forEach { entry in
            let (textView, delegate) = entry
            textView.delegate = delegate
        }
        oldTextViewDelegates.removeAllObjects()

        resolvedTextFieldDelegates().forEach { entry in
            let (textField, delegate) = entry
            textField.delegate = delegate
        }
        oldTextFieldDelegates.removeAllObjects()
    }

    func insertInputView(inputView: UIView, at: Int) {
        self.inputViews.insertPointer(Unmanaged.passUnretained(inputView).toOpaque(), at: at)
        configureInputView(inputView: inputView)
        configureInputAccessoryViews(inputViews: resolvedInputViews())
    }

    func removeInputView(inputView: UIView) {
        let views = resolvedInputViews()
        let index = views.firstIndex(of: inputView)!
        self.inputViews.removePointer(at: index)
        if let textField = inputView as? UITextField {
            let oldDelegate = oldTextFieldDelegates.object(forKey: textField)
            oldTextFieldDelegates.removeObject(forKey: textField)
            textField.delegate = oldDelegate
        } else if let textView = inputView as? UITextView {
            let oldDelegate = oldTextViewDelegates.object(forKey: textView)
            oldTextViewDelegates.removeObject(forKey: textView)
            textView.delegate = oldDelegate
        } else {
            fatalError("Unsupported responder type.")
        }

        if allowTraversal {
            if currentInputView === inputView {
                if inputViews.count == 0 {
                    currentInputView?.resignFirstResponder()
                } else if index == views.startIndex {
                    currentInputView = views[index + 1]
                } else {
                    currentInputView = views[index - 1]
                }
                currentInputView?.becomeFirstResponder()
            }

            configureInputAccessoryViews(inputViews: views)
        }
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
        guard let currentInputViewIndex = resolvedInputViews().firstIndex(of: currentInputView) else {
            logger?.logWarning(message: String(format: "[%@] currentInputView not found in inputViews: %@.", instanceType(self), String(describing: inputViews)))
            return
        }
        let nextIdx = currentInputViewIndex + 1
        let nextField = resolvedInputViews()[nextIdx]
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
        guard let currentInputViewIndex = resolvedInputViews().firstIndex(of: currentInputView) else {
            logger?.logWarning(message: String(format: "[%@] currentInputView not found in inputViews: %@.", instanceType(self), String(describing: inputViews)))
            return
        }
        let previousIdx = currentInputViewIndex - 1
        let previousField = resolvedInputViews()[previousIdx]
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

    func configureInputView(inputView: UIView) {
        if let textField = inputView as? UITextField {
            oldTextFieldDelegates.setObject(textField.delegate, forKey: textField)
            textField.delegate = self
            if resolvedInputViews().firstIndex(of: textField)! < inputViews.count - 1 {
                textField.returnKeyType = .next
            } else {
                textField.returnKeyType = .done
            }
        } else if let textView = inputView as? UITextView {
            oldTextViewDelegates.setObject(textView.delegate, forKey: textView)
            textView.delegate = self
        } else {
            fatalError("Unsupported responder type.")
        }
    }

    func configureInputAccessoryViews(inputViews: [UIView]) {
        inputViews.forEach {
            if let textField = $0 as? UITextField {
                if let inputAccessory = textField.inputAccessoryView as? FormControllerInputAccessoryView {
                    if allowTraversal {
                        inputAccessory.nextButton?.isEnabled = isEnabled(view: textField, inputViews: inputViews, previous: false)
                        inputAccessory.previousButton?.isEnabled = isEnabled(view: textField, inputViews: inputViews, previous: true)
                    }
                } else {
                    textField.inputAccessoryView = accessoryViewForInputView(view: textField, inputViews: inputViews)
                }
            } else if let textView = $0 as? UITextView {
                if let inputAccessory = textView.inputAccessoryView as? FormControllerInputAccessoryView {
                    if allowTraversal {
                        inputAccessory.nextButton?.isEnabled = isEnabled(view: textView, inputViews: inputViews, previous: false)
                        inputAccessory.previousButton?.isEnabled = isEnabled(view: textView, inputViews: inputViews, previous: true)
                    }
                } else {
                    textView.inputAccessoryView = accessoryViewForInputView(view: textView, inputViews: inputViews)
                }
            }
        }
    }

    func isEnabled(view: UIView, inputViews: [UIView], previous: Bool) -> Bool {
        guard let idx = inputViews.firstIndex(of: view) else {
            return false
        }
        let isEnabled = previous ? idx > 0 : idx < inputViews.count - 1
        return isEnabled
    }

    func accessoryViewForInputView(view: UIView, inputViews: [UIView]) -> UIView {
        var previousButtonOrNil: UIBarButtonItem? = nil
        var nextButtonOrNil: UIBarButtonItem? = nil

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12

        let toolbar = FormControllerInputAccessoryToolbar(frame: .zero)
        var items = [UIBarButtonItem]()
        if allowTraversal && inputViews.count > 0 {
            let previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(previousTextField))
            previousButton.isEnabled = isEnabled(view: view, inputViews: inputViews, previous: true)

            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextInputView))
            nextButton.isEnabled = isEnabled(view: view, inputViews: inputViews, previous: false)

            items.append(contentsOf: [
                space,
                previousButton,
                space,
                nextButton
            ])

            nextButtonOrNil = nextButton
            previousButtonOrNil = previousButton
        }
        items.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton,
            space
        ])
        toolbar.items = items

        let view = FormControllerInputAccessoryView(nextButton: nextButtonOrNil, previousButton: previousButtonOrNil, frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        view.addSubview(toolbar)
        toolbar.edgeAnchors == view.edgeAnchors
        return view
    }

    func inputView(forCell cell: UITableViewCell) -> UIView? {
        guard let tableView = tableView else { return nil }
        guard let window = UIApplication.shared.keyWindow else { return nil }
        let absoluteCellFrame = window.convert(cell.frame, from: tableView)
        return resolvedInputViews().filter { view in
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

    func unhide(keyboardFrame: CGRect) {
        guard let currentInputView = self.currentInputView else {
            self.environment?.logger?.logWarning(message: "No current input view.")
            return
        }
        if let scrollView = self.scrollView, !self.insetScrollViewContentForAccessoryView, let inputAccessoryView = currentInputView.inputAccessoryView {
            self.insetScrollViewContentForAccessoryView = true

//                self.visualDebugWindow.rootViewController?.view.subviews.forEach {
//                    $0.removeFromSuperview()
//                }
//
//                let currentInputViewFrame = self.visualDebugWindow.convert(currentInputView.frame, from: scrollView)
//
//                let inputViewFrameDebugRectView = UIView(frame: currentInputViewFrame)
//                inputViewFrameDebugRectView.layer.borderColor = UIColor.red.cgColor
//                inputViewFrameDebugRectView.layer.borderWidth = 2
//                self.visualDebugWindow.rootViewController?.view.addSubview(inputViewFrameDebugRectView)
//
//                let keyboardFrameDebugRectView = UIView(frame: keyboardFrame)
//                keyboardFrameDebugRectView.layer.borderColor = UIColor.red.cgColor
//                keyboardFrameDebugRectView.layer.borderWidth = 2
//                self.visualDebugWindow.rootViewController?.view.addSubview(keyboardFrameDebugRectView)


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

    func handleKeyboardDisplay(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            self.environment?.logger?.logWarning(message: "No keyboard frame could be retrieved from the notification.")
            return
        }

        if self.originalContentInset == nil {
            guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                self.environment?.logger?.logWarning(message: "No animation duration could be retrieved from the notification.")
                return
            }
            guard let curveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
                self.environment?.logger?.logWarning(message: "No animation curve could be retrieved from the notification.")
                return
            }
            guard let scrollView = self.tableView ?? self.scrollView else {
                self.environment?.logger?.logWarning(message: "No scroll view could be retrieved.")
                return
            }
            self.originalContentInset = scrollView.contentInset
            let curveOption = UIView.AnimationOptions(rawValue: curveRawValue)
            UIView.animate(withDuration: duration, delay: 0, options: curveOption, animations: {
                var insets = scrollView.contentInset
                insets.bottom = keyboardFrame.height - 49 // ???: assumed height of UITabBar? input accessory view? safe area bottom margin?
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = scrollView.contentInset.inset(bottomDelta: keyboardFrame.height)
            }) { [weak self] _ in
                self?.unhide(keyboardFrame: keyboardFrame)
            }
        } else {
            unhide(keyboardFrame: keyboardFrame)
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
            let observer = NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main) { [weak self] notification in
                guard let strongSelf = self else { return }
                let logger = strongSelf.environment?.logger
                switch notification.name {
                case UIResponder.keyboardWillChangeFrameNotification:
                    logger?.logDebug(message: String(format: "[%@] UIKeyboardWillChangeFrame", instanceType(strongSelf)))
                    if strongSelf.receivedDelegateCallback {
                        strongSelf.receivedDelegateCallback = false
                        strongSelf.notification = nil
                        strongSelf.handleKeyboardDisplay(notification: notification)
                    } else {
                        strongSelf.notification = notification
                    }
                    break
                case UIResponder.keyboardWillHideNotification:
                    logger?.logDebug(message: String(format: "[%@] UIKeyboardWillHide", instanceType(strongSelf)))
                    strongSelf.handleKeyboardHide(notification: notification)
                    break
                default: fatalError("Unexpected notification received")
                }
            }
            self.notificationObservers.append(observer)
        }

        let inputViews = resolvedInputViews()
        inputViews.forEach {
            configureInputView(inputView: $0)
        }
        configureInputAccessoryViews(inputViews: inputViews)
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

        if let delegate = oldTextViewDelegates.object(forKey: textView) {
            delegate.textViewDidBeginEditing?(textView)
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewDidEndEditing: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates.object(forKey: textView) {
            delegate.textViewDidEndEditing?(textView)
        }
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewShouldEndEditing: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates.object(forKey: textView), let result = delegate.textViewShouldEndEditing?(textView) {
            return result
        } else {
            return true
        }
    }

    public func textViewDidChange(_ textView: UITextView) {
        environment?.logger?.logDebug(message: String(format: "[%@] textViewDidChange: %@", instanceType(self), textView))
        if let delegate = oldTextViewDelegates.object(forKey: textView) {
            delegate.textViewDidChange?(textView)
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

        if let delegate = oldTextFieldDelegates.object(forKey: textField) {
            delegate.textFieldDidBeginEditing?(textField)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        environment?.logger?.logDebug(message: String(format: "[%@] textFieldDidEndEditing: %@", instanceType(self), textField))

        if let delegate = oldTextFieldDelegates.object(forKey: textField) {
            delegate.textFieldDidEndEditing?(textField)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = oldTextFieldDelegates.object(forKey: textField), let delegateResponse = delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return delegateResponse
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let idx = resolvedInputViews().firstIndex(of: textField)!
        if idx == inputViews.count - 1 {
            resignResponders()
        } else {
            nextInputView()
        }

        if let delegate = oldTextFieldDelegates.object(forKey: textField), let delegateResponse = delegate.textFieldShouldReturn?(textField) {
            return delegateResponse
        }

        return true
    }

}
