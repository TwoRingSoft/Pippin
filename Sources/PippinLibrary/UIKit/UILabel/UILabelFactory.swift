//
//  UILabelFactory.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

public extension UILabel {
    static func label(withText text: String? = nil, font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize), textColor: UIColor = .black, alignment: NSTextAlignment = .left, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        return label
    }
}
