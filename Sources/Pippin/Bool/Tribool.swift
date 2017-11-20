//
//  Tribool.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/31/16.
//  Copyright © 2017 andrew mcknight. All rights reserved.
//

/**
 See http://en.wikipedia.org/wiki/Three-valued_logic for an introduction to three valued logic. The truth table for the implemented logic functions follows:
```
                                   Kleene  Łukasiewicz
 | p q | ¬p | ¬q | p ∧ q | p v q | p → q | p → q |
 -------------------------------------------------
 | - - | +  | +  |   -   |   -   |   +   |   +   |
 | - 0 | +  | 0  |   -   |   0   |   +   |   +   |
 | - + | +  | -  |   -   |   +   |   +   |   +   |
 | 0 - | 0  | +  |   -   |   0   |   0   |   0   |
 | 0 0 | 0  | 0  |   0   |   0   |   0   |   +   |
 | 0 + | 0  | -  |   0   |   +   |   +   |   +   |
 | + - | -  | +  |   -   |   +   |   -   |   -   |
 | + 0 | -  | 0  |   0   |   +   |   0   |   0   |
 | + + | -  | -  |   +   |   +   |   +   |   +   |
 -------------------------------------------------
 ```
 */
public typealias Tribool = Bool?

enum Implication {

    case Kleene
    case Łukasiewicz
    
}

/**
 Constants specifying the numeric values of the three possible logical states. Based on assigned values from "balanced ternary logic": -1 for false, 0 for unknown, and +1 for true, or simply -, 0 and +.
 - note: These constants are represented as `_false` = -1, `_undecided` = 0 and `_true` = 1 to reduce the logical operations conjunction, disjunction, negation and the kleene and lukasiewicz implications to simple primitive operations.
 */
public enum TriboolValue: Int {

    /// The ternary logical value for "yes" or "true", defined in balanced ternary logic as +1.
    case _true = 1

    /// The ternary logical value for "unknown", "unknowable/undecidable", "irrelevant", or "both", defined in balanced ternary logic as 0.
    case _undecided = 0

    /// The ternary logical value for "no" or "false", defined in balanced ternary logic as -1.
    case _false = -1

    init(tribool: Tribool) {
        if tribool == nil {
            self = ._undecided
        } else {
            self = TriboolValue(bool: tribool!)
        }
    }

    init(bool: Bool) {
        self = bool ? ._true : ._false
    }

    func tribool() -> Tribool {
        switch self {
        case ._false:
            return false
        case ._true:
            return true
        case ._undecided:
            return nil
        }
    }

    /// - returns: `false` if either `_false` or `_undecided`, `true` otherwise
    func negativelyBiasedBoolean() -> Bool {
        if self == ._true {
            return true
        }

        return false
    }

    /// - returns: `true` if either `_true` or `_undecided`, `false` otherwise
    func positivelyBiasedBoolean() -> Bool {
        if self == ._false {
            return false
        }

        return true
    }

}

// MARK: Logical OR

public func ||(lhs: Tribool, rhs: Tribool) -> Tribool {
    let a = TriboolValue(tribool: lhs).rawValue
    let b = TriboolValue(tribool: rhs).rawValue
    let result = max(a, b)
    return TriboolValue(rawValue: result)!.tribool()
}

// MARK: Logical AND

public func &&(lhs: Tribool, rhs: Tribool) -> Tribool {
    let a = TriboolValue(tribool: lhs).rawValue
    let b = TriboolValue(tribool: rhs).rawValue
    let result = min(a, b)
    return TriboolValue(rawValue: result)!.tribool()
}

// MARK: Logical NOT

public prefix func !(receiver: Tribool) -> Tribool {
    let val = TriboolValue(tribool: receiver).rawValue
    return TriboolValue(rawValue: val * -1)!.tribool()
}

// MARK: Implication

infix operator →*
infix operator →→

/// Kleene implication
public func →*(lhs: Tribool, rhs: Tribool) -> Tribool {
    return imply(lhs: lhs, rhs: rhs, type: .Kleene)
}

/// Łukasiewicz implication
public func →→(lhs: Tribool, rhs: Tribool) -> Tribool {
    return imply(lhs: lhs, rhs: rhs, type: .Łukasiewicz)
}

func imply(lhs: Tribool, rhs: Tribool, type: Implication) -> Tribool {
    let a = TriboolValue(tribool: lhs).rawValue
    let b = TriboolValue(tribool: rhs).rawValue
    var result: Int
    switch type {
    case .Kleene:
        result = max(-1 * a, b)
    case .Łukasiewicz:
        result = min(1, 1 - a + b)
    }
    return TriboolValue(rawValue: result)!.tribool()
}
