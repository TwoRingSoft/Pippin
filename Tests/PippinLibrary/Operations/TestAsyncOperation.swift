//
//  TestAsyncOperation.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/8/18.
//

import Foundation
import PippinLibrary

/// A synchronous operation that simulates long running work by infinitely looping. Helps guarantee that it is executing without finishing too soon for in-flight cancellation tests.
public class TestInfiniteSyncOperation: Operation {
    public override func main() {
        while(true) {}
    }
}

/// An asynchronous operation that either completes immediately (to test completion blocks' execution and serial operation on queues) or runs forever (to test in-flight cancellation without having to worry about timing).
public class TestAsyncOperation: AsyncOperation {
    private var infinite: Bool
    
    @objc public init(infinite: Bool) {
        self.infinite = infinite
        super.init()
    }

    override public func main() {
        print("starting TestAsyncOperation \(String(describing: name))")
        if !infinite {
            self.finishWork()
        }
    }
    
    private func finishWork() {
        print("finishing TestAsyncOperation \(String(describing: name))")
        finish(withError: nil)
    }
    
    override public func cancel() {
        print("cancelled TestAsyncOperation \(String(describing: name))")
        let wasExecuting = isExecuting
        super.cancel()
        if wasExecuting {
            finishWork()
        }
    }
}
