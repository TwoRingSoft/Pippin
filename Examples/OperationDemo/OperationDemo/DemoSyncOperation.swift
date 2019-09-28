//
//  DemoSyncOperation.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Cocoa
import PippinLibrary

final class DemoSyncOperation: Operation {
    private var delegate: OperationStateChangeDelegate
    var color: NSColor
    
    init(delegate: OperationStateChangeDelegate) {
        self.delegate = delegate
        
        self.color = colors[Int(currentColor % colors.count)]
        currentColor += 1
        
        super.init()
        
        self.name = "sync \(syncOperationNumber)"
        syncOperationNumber += 1
        
        self.completionBlock = {
            self.delegate.operationSyncCompletionCalled(operation: self)
        }
    }
    
    override func main() {
        self.delegate.operationBeganExecuting(operation: self)
        self.delegate.operationSyncWorkFinished(operation: self)
        self.delegate.operationMainMethodFinished(operation: self)
    }
    
    override func cancel() {
        self.delegate.operationAsyncWorkCanceled(operation: self)
        super.cancel()
    }
}
