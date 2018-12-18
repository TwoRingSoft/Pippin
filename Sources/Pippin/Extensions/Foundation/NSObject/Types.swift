//
//  Types.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/21/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

public func instanceType(_ object: NSObject) -> String {
    return lastClassComponent(identifier: NSStringFromClass(type(of: object)))
}

public func classType(_ klass: AnyClass) -> String {
    return lastClassComponent(identifier: NSStringFromClass(klass))
}

public func valueType(_ value: Any) -> String {
    return String(describing: type(of: value))
}

fileprivate func lastClassComponent(identifier: String) -> String {
    return (identifier as NSString).components(separatedBy: ".").last!
}

public extension NSObject {
    func isOneOfPossibleKinds(_ kinds: [AnyClass]) -> Bool {
        return nil != kinds.first { isKind(of: $0) }
    }
}
