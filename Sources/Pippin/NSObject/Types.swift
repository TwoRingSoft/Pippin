//
//  Types.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/21/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

func instanceType(_ object: NSObject) -> String {
    return lastClassComponent(identifier: NSStringFromClass(type(of: object)))
}

func classType(_ klass: AnyClass) -> String {
    return lastClassComponent(identifier: NSStringFromClass(klass))
}

func valueType(_ value: Any) -> String {
    return String(describing: type(of: value))
}

fileprivate func lastClassComponent(identifier: String) -> String {
    return (identifier as NSString).components(separatedBy: ".").last!
}
