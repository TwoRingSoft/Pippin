//
//  FillingRoundedRectButton.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 8/8/17.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import QuartzCore
import UIKit

public class FillingRoundedRectButton: UIButton {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        set(highlighted: true, animated: true)
        super.touchesBegan(touches, with: event)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let contained = self.bounds.contains(location)
        set(highlighted: contained, animated: contained)
        super.touchesMoved(touches, with: event)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        set(highlighted: false, animated: false)
        super.touchesEnded(touches, with: event)
    }

    func set(highlighted: Bool, animated: Bool) {
        let newColor = highlighted ? self.tintColor.cgColor : UIColor.white.cgColor
        if animated {
            if self.layer.animationKeys()?.count ?? 0 == 0 {
                let animation = CABasicAnimation(keyPath: "backgroundColor")
                animation.fromValue = self.layer.backgroundColor
                animation.toValue = newColor
                animation.duration = 0.2
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                self.layer.add(animation, forKey: "animation\(self.layer.animationKeys()?.count ?? 0)")
            }
        } else {
            self.layer.removeAllAnimations()
            self.layer.backgroundColor = newColor
        }
    }

    public func configureRoundedRectButton(title: String, tintColor color: UIColor = .black, font: UIFont = UIFont.systemFont(ofSize: 17), borderWidth: CGFloat = 1, cornerRadius: CGFloat = 15, target: Any? = nil, selector: Selector? = nil) {
        configure(title: title, tintColor: color, font: font, target: target, selector: selector)

        // style border
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
}
