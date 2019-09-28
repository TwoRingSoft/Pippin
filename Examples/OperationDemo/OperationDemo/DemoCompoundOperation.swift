//
//  CompoundOperation.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Cocoa
import PippinLibrary

final class DemoCompoundOperation: CompoundOperation {
    private var delegate: OperationStateChangeDelegate
    private var color: NSColor

    init(delegate: OperationStateChangeDelegate) {
        self.delegate = delegate
        self.color = colors[currentColor % colors.count]
        currentColor += 1
        
        let op1 = DemoAsyncOperation(delegate: delegate)
        op1.asyncCompletionBlock = { error in
            delegate.operationAsyncCompletionCalled(operation: op1)
        }
        op1.completionBlock = {
            delegate.operationSyncCompletionCalled(operation: op1)
        }
        
        let op2 = DemoAsyncOperation(delegate: delegate)
        op2.asyncCompletionBlock = { error in
            delegate.operationAsyncCompletionCalled(operation: op2)
        }
        op2.completionBlock = {
            delegate.operationSyncCompletionCalled(operation: op2)
        }
        
        let op3 = DemoAsyncOperation(delegate: delegate)
        op3.asyncCompletionBlock = { error in
            delegate.operationAsyncCompletionCalled(operation: op3)
        }
        op3.completionBlock = {
            delegate.operationSyncCompletionCalled(operation: op3)
        }

        super.init(operations: [op1, op2, op3])
        
        self.name = "compound \(compoundOperationNumber)"
        compoundOperationNumber += 1
        
        self.compoundQueue.maxConcurrentOperationCount = 1
        
        self.completionBlock = {
            delegate.operationSyncCompletionCalled(operation: self)
        }
        
        self.asyncCompletionBlock = { errorOptional in
            if let error = errorOptional {
                delegate.operationAsyncCompletionCalled(operation: self, withError: error)
            } else {
                delegate.operationAsyncCompletionCalled(operation: self)
            }
        }
    }
    
    override func main() {
        super.main()
        delegate.operationMainMethodFinished(operation: self)
    }
}
