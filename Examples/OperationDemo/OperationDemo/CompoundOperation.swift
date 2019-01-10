//
//  CompoundOperation.swift
//  FABOperationDemo
//
//  Created by Andrew McKnight on 3/15/16.
//  Copyright © 2016 Twitter. All rights reserved.
//

import Cocoa
import Pippin

class DemoCompoundOperation: FABCompoundOperation {
    var delegate: OperationStateChangeDelegate!
    var imageView: NSImageView
    var color: NSColor

    init(imageView: NSImageView, color: NSColor, delegate: OperationStateChangeDelegate, name: String) {
        self.imageView = imageView
        self.color = color
        self.delegate = delegate

        super.init()

        self.completionBlock = {
            delegate.operationSyncCompletionCalled(self)
        }

        self.asyncCompletion = { errorOptional in
            if let error = errorOptional {
                delegate.operationAsyncCompletionCalled(self, withError: error)
            } else {
                delegate.operationAsyncCompletionCalled(self)
            }
        }

        self.name = name
        self.compoundQueue.maxConcurrentOperationCount = 1

        let op1 = DemoAsyncOperation(url: "https://upload.wikimedia.org/wikipedia/commons/c/c5/Number-One.JPG", imageView: imageView, color: NSColor.blueColor(), delegate: delegate, name: "\(name) async suboperation 1")
        op1.asyncCompletion = { error in
            delegate.operationAsyncCompletionCalled(op1)
        }
        op1.completionBlock = {
            delegate.operationSyncCompletionCalled(op1)
        }

        let op2 = DemoAsyncOperation(url: "https://upload.wikimedia.org/wikipedia/commons/1/18/Roman_Numeral_2.gif", imageView: imageView, color: NSColor.redColor(), delegate: delegate, name: "\(name) async suboperation 2")
        op2.asyncCompletion = { error in
            delegate.operationAsyncCompletionCalled(op2)
        }
        op2.completionBlock = {
            delegate.operationSyncCompletionCalled(op2)
        }

        let op3 = DemoAsyncOperation(url: "https://upload.wikimedia.org/wikipedia/commons/0/0a/Number-three.JPG", imageView: imageView, color: NSColor.orangeColor(), delegate: delegate, name: "\(name) async suboperation 3")
        op3.asyncCompletion = { error in
            delegate.operationAsyncCompletionCalled(op3)
        }
        op3.completionBlock = {
            delegate.operationSyncCompletionCalled(op3)
        }
        
        self.operations = [ op1, op2, op3 ]
    }
}
