//
//  CGSize+Init.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/2/19.
//

import Foundation
import CoreGraphics

public extension CGSize {
    init(size: CGFloat) {
        self.init(width: size, height: size)
    }
    
    init(size: Int) {
        self.init(width: size, height: size)
    }
    
    init(size: Double) {
        self.init(width: size, height: size)
    }
}
