//
//  UILabelFactory.swift
//  McMileage
//
//  Created by Andrew McKnight on 10/24/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import Foundation

func label(withText text: String) -> UILabel {
    let label = UILabel(frame: .zero)
    label.text = text
    return label
}
