//
//  NaiveAsyncOperation.swift
//  OperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2018 Two Ring Software. All rights reserved.
//

import Cocoa
import PippinLibrary

/// Simulates an implementation of asynchronous work using a stock `Operation`. When many of these are executed on a serial queue or with dependency order, operations begin before the async work being done by those before them actually finishes.
/// - SeeAlso: OperationDemoUITests.
final class NaiveAsyncOperation: Operation {
    private var delegate: OperationStateChangeDelegate
    var color: NSColor
    
    init(delegate: OperationStateChangeDelegate) {
        self.delegate = delegate
        
        self.color = colors[Int(currentColor % colors.count)]
        currentColor += 1
        
        super.init()
        
        self.name = "naive async \(naiveAsyncOperationNumber)"
        naiveAsyncOperationNumber += 1
        
        self.completionBlock = {
            self.delegate.operationSyncCompletionCalled(operation: self)
        }
    }
    
    override func main() {
        self.delegate.operationBeganExecuting(operation: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.delegate.operationAsyncWorkFinished(operation: self)
        })
        self.delegate.operationMainMethodFinished(operation: self)
    }
    
    override func cancel() {
        self.delegate.operationAsyncWorkCanceled(operation: self)
        super.cancel()
    }
}
