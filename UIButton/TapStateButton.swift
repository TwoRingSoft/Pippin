//
//  TapStateButton.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/15/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

func createButtonWithImageSetName(imageSetName: String, tintColor: UIColor = UIColor.whiteColor()) -> UIButton {
    let button = UIButton(type: .Custom)
    button.tintColor = tintColor
    button.setImage(UIImage(named: "\(imageSetName)"), forState: .Normal)
    button.setImage(UIImage(named: "\(imageSetName)-filled"), forState: .Highlighted)
    button.setImage(UIImage(named: "\(imageSetName)-filled"), forState: .Selected)
    return button

}
