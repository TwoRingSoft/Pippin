//
//  CGPoint+Factory.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/6/17.
//

import UIKit

public extension CGPoint {
    func offset(xDelta: CGFloat = 0, yDelta: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + xDelta, y: y + yDelta)
    }
}
