//
//  UITextFieldFactory.swift
//  McMileage
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

extension UITextField {

    static func textField(withPlaceholder placeholder: String?, text: String?) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        return textField
    }
    
}
