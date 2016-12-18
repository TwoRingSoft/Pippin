//
//  UILabelFactory.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

extension UILabel {

    static func label(withText text: String, font: UIFont, textColor: UIColor = .black, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        return label
    }
    
}
