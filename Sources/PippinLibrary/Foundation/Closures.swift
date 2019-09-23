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

/// A closure that accepts a boolean representing if an operation completed successfully, to decide whether to retrieve confirmation from `confirmBlock`.
///
/// This provides a way for a consumer application to provide custom UI/UX before returning control here to e.g. kill the app to reload a debug database.
public typealias ConfirmCompletionBlock = ((_ success: Bool, _ confirmBlock: @escaping BooleanBlock) -> ())
