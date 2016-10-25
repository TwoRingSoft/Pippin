//
//  UILabelFactory.swift
//  McMileage
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

func label(withText text: String, font: UIFont, textColor: UIColor = .black) -> UILabel {
    let label = UILabel(frame: .zero)
    label.text = text
    label.font = font
    label.textColor = textColor
    return label
}
