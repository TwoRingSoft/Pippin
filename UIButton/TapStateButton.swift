//
//  TapStateButton.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/15/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

/**
 - description: Create a UIButton with a tintColor and an image for `.Normal` and `.Highlighted`/`.Selected` states. The images should be template rendered in the asset catalog.
 - parameters:
    - imageSetName: name of the image set in Asset catalog to use for `.Normal` state
    - emphasisSuffix: suffix to append to `imageSetName` to show for `.Highlighted` and `.Selected` states (defaults to empty string to use same image for everything)
    - tintColor: the tint color to use on the images (defaults to white)
 */
func createButtonWithImageSetName(imageSetName: String, emphasisSuffix: String = "", tintColor: UIColor = UIColor.whiteColor()) -> UIButton {
    let button = UIButton(type: .Custom)
    button.tintColor = tintColor
    button.setImage(UIImage(named: "\(imageSetName)"), forState: .Normal)
    button.setImage(UIImage(named: "\(imageSetName)\(emphasisSuffix)"), forState: .Highlighted)
    button.setImage(UIImage(named: "\(imageSetName)\(emphasisSuffix)"), forState: .Selected)
    return button
}
