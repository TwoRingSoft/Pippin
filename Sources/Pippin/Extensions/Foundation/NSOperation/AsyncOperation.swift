//
//  AsyncOperation.swift
//  Anchorage
//
//  Created by Andrew McKnight on 8/30/18.
//

import Foundation

/// A subclass of the synchronous `Operation`, extended to function as a base class for subclasses encapsulating asynchronous operations, e.g. network calls.
///
/// Subclasses should override `main()` to implement their logic, and ensure that `finish(withError:)` is called to complete the operation.
///
/// Consumers of operations may set an optional closure for `asyncCompletionBlock`, that executes when the asynchronous task is finished, and contains any error reported.
public class AsyncOperation: Operation {
    private var _executing: Bool = false
    private var _finished: Bool = false
    private let lock = NSRecursiveLock()
    
    /// A closure to execute when the asynchronous work has finished in the operation.
    ///
    /// - Note: Differs from `Operation.completionBlock` in that `completionBlock` executes once `main()` returns, meaning that the asynchronous task, e.g. network request, has been started, but not necessarily finished. `completionBlock` always completes before `asyncCompletionBlock`.
    public var asyncCompletionBlock: ErrorBlock?
    
    public override init() {
        lock.name = String(asRDNSForPippinSubpaths: ["lock", classType(AsyncOperation.self)])
        super.init()
    }
    
    public override var isConcurrent: Bool { return true }
    public override var isAsynchronous: Bool { return true }
    
    public override var isExecuting: Bool {
        lock.lock()
        let result = _executing
        lock.unlock()
        return result
    }
    
    public override var isFinished: Bool {
        lock.lock()
        let result = _finished
        lock.unlock()
        return result
    }
    
    public override func start() {
        guard !isCancelled() else { return }
        markStarted()
        main()
    }
    
    /// Used by subclasses to complete the operation and, if necessary, pass back error information.
    ///
    /// - Parameter error: An error encountered by the async operation, if any.
    public func finish(withError error: Error?) {
        asyncCompletionBlock?(error)
        markDone()
    }
}

// MARK: Private
private extension AsyncOperation {
    func isCancelled() -> Bool {
        if isCancelled {
            markDone()
            return true
        } else {
            return false
        }
    }
    
    func markStarted() {
        lock {
            updateObservedState(key: \AsyncOperation.isExecuting) {
                _executing = true
            }
        }
    }
    
    func markDone() {
        lock {
            updateObservedState(key: \AsyncOperation.isExecuting) {
                _executing = false
            }
            updateObservedState(key: \AsyncOperation.isFinished) {
                _finished = true
            }
        }
    }

    func lock(closure: EmptyBlock) {
        lock.lock()
        closure()
        lock.unlock()
    }
    
    func updateObservedState(key: KeyPath<AsyncOperation, Bool>, closure: EmptyBlock) {
        willChangeValue(for: key)
        closure()
        didChangeValue(for: key)
    }
}
