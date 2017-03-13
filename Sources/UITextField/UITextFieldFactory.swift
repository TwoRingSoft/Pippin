//
//  UITextFieldFactory.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

extension UITextField {

    static func textField(withPlaceholder placeholder: String? = nil, text: String? = nil, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        return textField
    }
    
}