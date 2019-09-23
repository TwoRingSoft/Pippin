//
//  CAGradientLayer+ColorGradientLayer.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/1/18.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Foundation

public final class ColorGradientLayer: CAGradientLayer {
    override public init() {
        super.init()
        var gradientColors = [CGColor]()
        for hue in 0 ..< 7 {
            gradientColors.append(UIColor(hue: CGFloat(hue)/6.0, saturation: 1, brightness: 1, alpha: 1).cgColor)
        }
        colors = gradientColors
        startPoint = CGPoint(x: 0.0, y: 0.5)
        endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
