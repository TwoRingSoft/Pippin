//
//  UIButtonFactory.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/15/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

extension UIButton {

    /**
     - description: Create a UIButton with a tintColor and an image for `.Normal` and `.Highlighted`/`.Selected` states. The images should be template rendered in the asset catalog.
     - parameters:
     - imageSetName: name of the image set in Asset catalog to use for `.Normal` state
     - emphasisSuffix: suffix to append to `imageSetName` to show for `.Highlighted` and `.Selected` states (defaults to empty string to use same image for everything)
     - tintColor: the tint color to use on the images (defaults to white)
     - target: target to receive a `touchUpInside` event
     - selector: function to call for a `touchUpInside` event
     */
    class func button(withImageSetName imageSetName: String, emphasisSuffix: String = "", tintColor: UIColor = UIColor.white, target: Any? = nil, selector: Selector? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.tintColor = tintColor
        button.setImage(UIImage(named: "\(imageSetName)"), for: .normal)
        button.setImage(UIImage(named: "\(imageSetName)\(emphasisSuffix)"), for: .highlighted)
        button.setImage(UIImage(named: "\(imageSetName)\(emphasisSuffix)"), for: .selected)
        if selector != nil {
            button.addTarget(target, action: selector!, for: .touchUpInside)
        }
        return button
    }

    class func button(withTitle title: String, tintColor color: UIColor = .black, target: Any? = nil, selector: Selector? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        if let rgb = color.rgb() {
            let lightColor = UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 0.5)
            button.setTitleColor(lightColor, for: .highlighted)
            button.setTitleColor(lightColor, for: .disabled)
        }
        if selector != nil {
            button.addTarget(target, action: selector!, for: .touchUpInside)
        }
        return button
    }
    
}
