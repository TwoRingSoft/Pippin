//
//  OperationStateChangeDelegate.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Cocoa

protocol OperationStateChangeDelegate {
    // TODO: rename to something like beganExecuting(delegator: OperationStateChangeDelegator)
    func operationBeganExecuting(operation: Operation)
    func operationMainMethodFinished(operation: Operation)
    func operationAsyncWorkCanceled(operation: Operation)
    func operationSyncWorkFinished(operation: Operation)
    func operationAsyncWorkFinished(operation: Operation)
    func operationAsyncWorkFailed(operation: Operation)
    func operationSyncCompletionCalled(operation: Operation)
    func operationAsyncCompletionCalled(operation: Operation)
    func operationAsyncCompletionCalled(operation: Operation, withError error: Error)
}
