//
//  Tribool.swift
//  shared-utils
//
//  Created by Andrew McKnight on 10/31/16.
//  Copyright © 2017 andrew mcknight. All rights reserved.
//

/**
 The MCKTribool class encapsulates the values and operations of ternary logic. See http://en.wikipedia.org/wiki/Three-valued_logic for an introduction. The truth table for the implemented logic functions follows:
 @code
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
 */
typealias Tribool = Bool?