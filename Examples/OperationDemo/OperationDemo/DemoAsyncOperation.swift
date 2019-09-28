//
//  AsyncOperation.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Cocoa
import PippinLibrary

final class DemoAsyncOperation: AsyncOperation {
    private var delegate: OperationStateChangeDelegate
    var color: NSColor
    private var queue = OperationQueue()
    
    init(delegate: OperationStateChangeDelegate) {
        self.delegate = delegate
        self.color = colors[currentColor % colors.count]
        currentColor += 1
        
        queue.maxConcurrentOperationCount = 1
        
        super.init()
        
        self.name = "async \(asyncOperationNumber)"
        asyncOperationNumber += 1
        
        self.completionBlock = {
            self.delegate.operationSyncCompletionCalled(operation: self)
        }
        
        self.asyncCompletionBlock = { errorOptional in
            if let error = errorOptional {
                self.delegate.operationAsyncCompletionCalled(operation: self, withError: error)
            } else {
                self.delegate.operationAsyncCompletionCalled(operation: self)
            }
        }
    }
    
    override func main() {
        self.delegate.operationBeganExecuting(operation: self)
        queue.addOperation {
            sleep(3)
        }
        queue.addOperation {
            self.delegate.operationAsyncWorkFinished(operation: self)
            self.finish(withError: nil)
        }
        self.delegate.operationMainMethodFinished(operation: self)
    }
    
    override func cancel() {
        self.delegate.operationAsyncWorkCanceled(operation: self)
        queue.cancelAllOperations()
        super.cancel()
    }
}
