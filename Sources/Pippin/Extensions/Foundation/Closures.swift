//
//  Closures.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/3/18.
//

import Foundation

/// A closure with no inputs.
public typealias EmptyBlock = (() -> (Void))

/// A closure with a boolean input.
public typealias BooleanBlock = ((Bool) -> (Void))

/// A closure passing an optional `Error`.
public typealias ErrorBlock = (Error?) -> (Void)

public typealias URLSessionCompletion = (URL?, URLResponse?, Error?) -> (Void)
