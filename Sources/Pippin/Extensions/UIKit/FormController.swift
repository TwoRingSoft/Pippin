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

    fileprivate var responders: [UIResponder]!
    fileprivate var oldTextFieldDelegates: [UITextField: UITextFieldDelegate?] = [:]
    fileprivate var oldTextViewDelegates: [UITextView: UITextViewDelegate?] = [:]
    fileprivate var currentResponder: UIResponder?

    public init(responders: [UIResponder]) {
        super.init()
        self.responders = responders

        for responder in responders {
            if let textField = responder as? UITextField {
                oldTextFieldDelegates[textField] = textField.delegate
                textField.delegate = self
                textField.inputAccessoryView = accessoryViewForResponder(responder: textField)
                if responders.index(of: responder)! < responders.count - 1 {
                    textField.returnKeyType = .next
                } else {
                    textField.returnKeyType = .done
                }
            } else if let textView = responder as? UITextView {
                oldTextViewDelegates[textView] = textView.delegate
                textView.delegate = self
                textView.inputAccessoryView = accessoryViewForResponder(responder: textView)
                if responders.index(of: responder)! < responders.count - 1 {
                    textView.returnKeyType = .next
                } else {
                    textView.returnKeyType = .done
                }
            } else {
                fatalError("Unsupported responder type.")
            }
        }
    }

}

// MARK: Public
public extension FormController {

    func resignResponders() {
        for responder in responders {
            responder.resignFirstResponder()
        }
    }

    func accessoryViewForResponder(responder: UIResponder) -> UIView {
        let previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(previousTextField))
        if let idx = responders.index(of: responder) {
            previousButton.isEnabled = idx > 0
        } else {
            previousButton.isEnabled = false
        }
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTextField))
        if let idx = responders.index(of: responder) {
            nextButton.isEnabled = idx < responders.count - 1
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

}

extension FormController: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        currentResponder = textView
        if let delegate = oldTextViewDelegates[textView], let unwrappedDelegate = delegate {
            unwrappedDelegate.textViewDidBeginEditing?(textView)
        }
    }

}

extension FormController: UITextFieldDelegate {

    // MARK: UITextField traversal

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        currentResponder = textField
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
        let idx = responders.index(of: textField)!
        if idx == responders.count - 1 {
            resignResponders()
        } else {
            nextTextField()
        }

        if let delegate = oldTextFieldDelegates[textField], let unwrappedDelegate = delegate, let delegateResponse = unwrappedDelegate.textFieldShouldReturn?(textField) {
            return delegateResponse
        }

        return true
    }

}

@objc extension FormController {

    func donePressed() {
        resignResponders()
    }

    func nextTextField() {
        let nextIdx = responders.index(of: currentResponder!)! + 1
        responders[nextIdx].becomeFirstResponder()
    }

    func previousTextField() {
        let previousIdx = responders.index(of: currentResponder!)! - 1
        responders[previousIdx].becomeFirstResponder()
    }

}
