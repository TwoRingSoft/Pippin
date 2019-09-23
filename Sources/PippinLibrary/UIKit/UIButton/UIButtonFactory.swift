//
//  UIButtonFactory.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/15/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import UIKit

public extension UIButton {
    /**
     - description: Create a UIButton with a tintColor and an image for `.Normal` and `.Highlighted`/`.Selected` states. The images should be template rendered in the asset catalog.
     - parameters:
     - imageSetName: name of the image set in Asset catalog to use for `.Normal` state
     - emphasisSuffix: suffix to append to `imageSetName` to show for `.Highlighted` and `.Selected` states (defaults to empty string to use same image for everything)
     - tintColor: the tint color to use on the images (defaults to white)
     - target: target to receive a `touchUpInside` event
     - selector: function to call for a `touchUpInside` event
     */
    class func button(withImageSetName imageSetName: String, emphasisSuffix: String = "", title: String? = nil, tintColor: UIColor = UIColor.white, font: UIFont? = nil, target: Any? = nil, selector: Selector? = nil, imageBundle: Bundle? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        let normalImage = UIImage(named: "\(imageSetName)", in: imageBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(normalImage, for: .normal)
        let emphasizedImage = UIImage(named: "\(imageSetName)\(emphasisSuffix)", in: imageBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(emphasizedImage, for: .highlighted)
        button.setImage(emphasizedImage, for: .selected)
        if selector != nil {
            button.addTarget(target, action: selector!, for: .touchUpInside)
        }
        button.tintColor = tintColor
        button.titleLabel?.font = font
        if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
        }
        return button
    }

    func configure(withImageSetName imageSetName: String? = nil, emphasisSuffix: String = "", title: String? = nil, tintColor color: UIColor = .black, font: UIFont = UIFont.systemFont(ofSize: 17), target: Any? = nil, selector: Selector? = nil, imageBundle: Bundle? = nil) {
        setTitle(title, for: .normal)

        if let imageSetName = imageSetName {
            let normalImage = UIImage(named: "\(imageSetName)", in: imageBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            setImage(normalImage, for: .normal)
            let emphasizedImage = UIImage(named: "\(imageSetName)\(emphasisSuffix)", in: imageBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            setImage(emphasizedImage, for: .highlighted)
            setImage(emphasizedImage, for: .selected)
        }

        if selector != nil {
            addTarget(target, action: selector!, for: .touchUpInside)
        }

        // universal styles
        tintColor = color
        titleLabel?.font = font

        // style normal state
        setTitleColor(color, for: .normal)

        // style disabled state
        if let rgb = color.rgb() {
            let lightColor = UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 0.5)
            setTitleColor(lightColor, for: .disabled)
        }

        // style highlighted state
        setTitleColor(.white, for: .highlighted)
        clipsToBounds = true
    }
}
