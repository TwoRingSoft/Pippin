//
//  FormController.swift
//  Dough
//
//  Created by Andrew McKnight on 1/11/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

class FormController: NSObject {

    fileprivate var textFields: [UITextField]!
    fileprivate var oldTextFieldDelegates: [UITextField: UITextFieldDelegate?] = [:]
    fileprivate var currentTextField: UITextField?

    init(textFields: [UITextField]) {
        super.init()
        self.textFields = textFields

        for textField in textFields {
            oldTextFieldDelegates[textField] = textField.delegate
            textField.delegate = self
            textField.inputAccessoryView = accessoryViewForTextField(textField: textField)
            if textFields.index(of: textField)! < textFields.count - 1 {
                textField.returnKeyType = .next
            } else {
                textField.returnKeyType = .done
            }
        }
    }

}

extension FormController: UITextFieldDelegate {

    // MARK: UITextField traversal

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate {
            if unwrappedDelegate.responds(to: #selector(UITextFieldDelegate.textField(_:shouldChangeCharactersIn:replacementString:))) {
                return unwrappedDelegate.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
            }
        }

        return true
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

extension FormController {

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

    func resignResponders() {
        for responder in textFields {
            responder.resignFirstResponder()
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
