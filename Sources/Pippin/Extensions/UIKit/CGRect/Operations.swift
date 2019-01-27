//
//  Operations.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/31/16.
//  Copyright © 2016 andrew mcknight. All rights reserved.
//

import UIKit

public extension CGRect {
    func subtracting(other: CGRect, edge: CGRectEdge) -> CGRect {
        let intersection = self.intersection(other)

        if intersection.isNull { return self }

        let chopAmount = (edge == .minXEdge || edge == .maxXEdge) ? intersection.width : intersection.height
        return self.divided(atDistance: chopAmount, from: edge).remainder
    }

    func insetting(by insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: origin.x + insets.left, y: origin.y + insets.top, width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
}
