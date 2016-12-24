//
//  DataInputFormViewController.swift
//  shared-utils
//
//  Created by Andrew McKnight on 12/23/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

class DataInputFormViewController: UIViewController {

    fileprivate var scrollView: UIScrollView!
    fileprivate var formView: UIView!

    fileprivate var textFields: [UITextField]!
    
    fileprivate var currentTextField: UITextField?
    fileprivate var keyboardFrame: CGRect?

    init(textFields: [UITextField], formConfigure: ((UIView) -> Void)) {
        super.init(nibName: nil, bundle: nil)

        self.textFields = textFields

        formView = UIView(frame: .zero)
        formConfigure(formView)

        scrollView = UIScrollView(frame: .zero)
        
        scrollView.addSubview(formView)
        view.addSubview(scrollView)
        
        formView.widthAnchor == scrollView.widthAnchor
        formView.heightAnchor == scrollView.heightAnchor
        formView.centerAnchors == scrollView.centerAnchors
        scrollView.edgeAnchors == view.edgeAnchors
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DataInputFormViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        watchKeyboardNotifications()

        for textField in textFields {
            textField.delegate = self
            textField.inputAccessoryView = accessoryViewForTextField(textField: textField)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = formView.intrinsicContentSize
    }

}

extension DataInputFormViewController: UITextFieldDelegate {

    // MARK: UITextField traversal

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        if keyboardFrame != nil {
            position(textField: textField, aboveKeyboardRect: keyboardFrame!)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let idx = textFields.index(of: textField)!
        if idx == textFields.count - 1 {
            resignResponders()
        } else {
            nextTextField()
        }

        return true
    }

}

extension DataInputFormViewController {

    func donePressed() {
        resignResponders()
    }

    func nextTextField() {
        let nextIdx = textFields.index(of: currentTextField!)! + 1
        textFields[nextIdx].becomeFirstResponder()
    }

    func previousTextField() {
        let previousIdx = textFields.index(of: currentTextField!)! - 1
        textFields[previousIdx].becomeFirstResponder()
    }

    func position(textField: UITextField, aboveKeyboardRect keyboardRect: CGRect) {
        guard let rootView = AppDelegate.getAppDelegate().window?.rootViewController?.view else {

            return
        }

        let convertedScrollviewRect = scrollView.convert(scrollView.bounds, to: rootView)
        let convertedTextFieldRect = textField.convert(textField.bounds, to: rootView)
        let visibleRect = convertedScrollviewRect.subtracting(other: keyboardRect, edge: .maxYEdge)

        // inset from visibleRect to provide padding between final location and top of view or keyboard
        let movementRect = visibleRect.insetting(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))

        if visibleRect.contains(convertedTextFieldRect) { return }

        // if the textField isn't completely inside visibleRect, then it's either above or below it
        // find out which and calculate the distance to move using movementRect
        var difference: CGFloat
        if convertedTextFieldRect.minY < movementRect.minY {
            difference = -(movementRect.minY - convertedTextFieldRect.minY)
        } else {
            difference = convertedTextFieldRect.maxY - movementRect.maxY // negative as this needs to scroll up
        }

        scrollView.setContentOffset(CGPoint(x: 0, y: difference + scrollView.contentOffset.y), animated: true)
    }

    func watchKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: OperationQueue.main) { note in
            guard let currentTextField = self.currentTextField,
                let keyboardRect = (note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

                    return
            }

            self.keyboardFrame = keyboardRect
            self.position(textField: currentTextField, aboveKeyboardRect: keyboardRect)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: OperationQueue.main) { note in
            self.keyboardFrame = nil

            guard let currentTextField = self.currentTextField else {
                return
            }

            self.position(textField: currentTextField, aboveKeyboardRect: CGRect(x: 0, y: self.view.bounds.height, width: 0, height: 0))
        }
    }

    func resignResponders() {
        for responder in textFields {
            responder.resignFirstResponder()
        }
        if scrollView.contentOffset.y != 0 {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }

    func accessoryViewForTextField(textField: UITextField) -> UIView {
        let previousButton = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(previousTextField))
        if let idx = textFields.index(of: textField) {
            previousButton.isEnabled = idx > 0
        } else {
            previousButton.isEnabled = false
        }
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTextField))
        if let idx = textFields.index(of: textField) {
            nextButton.isEnabled = idx < textFields.count - 1
        } else {
            nextButton.isEnabled = false
        }

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))

        let toolbar = UIToolbar(frame: .zero)
        toolbar.items = [
            previousButton,
            nextButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]

        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        view.backgroundColor = .lightGray
        view.addSubview(toolbar)
        toolbar.edgeAnchors == view.edgeAnchors
        return view
    }

}
