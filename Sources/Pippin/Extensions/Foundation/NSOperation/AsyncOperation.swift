//
//  AsyncOperation.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/30/18.
//

import Foundation

/// A subclass of the synchronous `Operation`, extended to function as a base class for subclasses encapsulating asynchronous operations, e.g. network calls.
///
/// Subclasses must override two functions:
///   - `main()` to implement their logic, and ensure that `finish(withError:)` is called to complete the operation
///   - `cancel()` to respond to cancellation events and stop any in-flight async work possible
///
/// Consumers of operations may set an optional closure for `asyncCompletionBlock`, that executes when the asynchronous task is finished, and contains any error reported.
open class AsyncOperation: Operation {
    private var _executing: Bool = false
    private var _finished: Bool = false
    private var _cancelled: Bool = false
    private let lock = NSRecursiveLock()
    
    /// A closure to execute when the asynchronous work has finished in the operation.
    ///
    /// - Note: Differs from `Operation.completionBlock` in that `completionBlock` executes once `main()` returns, meaning that the asynchronous task, e.g. network request, has been started, but not necessarily finished. `completionBlock` always completes before `asyncCompletionBlock`.
    @objc public var asyncCompletionBlock: ErrorBlock?
    
    public override init() {
        super.init()
        lock.name = String(asRDNSForPippinSubpaths: ["lock", classType(AsyncOperation.self)])
    }
    
    open override var isConcurrent: Bool { return true }
    open override var isAsynchronous: Bool { return true }
    
    @objc open override dynamic var isExecuting: Bool {
        lock.lock()
        let result = _executing
        lock.unlock()
        return result
    }
    
    @objc open override dynamic var isFinished: Bool {
        lock.lock()
        let result = _finished
        lock.unlock()
        return result
    }
    
    @objc open override dynamic var isCancelled: Bool {
        lock.lock()
        let result = _cancelled
        lock.unlock()
        return result
    }
    
    open override func start() {
        guard !isCancelled else {
            markDone()
            return
        }
        
        markStarted()
        main()
    }
    
    open override func cancel() {
        if _executing {
            completionBlock = nil
        }
        lock {
            updateObservedState(key: \AsyncOperation.isCancelled, closure: { () -> (Void) in
                _cancelled = true
            })
        }
        super.cancel()
        markDone()
    }
    
    /// Used by subclasses to complete the operation and, if necessary, pass back error information.
    ///
    /// - Parameter error: An error encountered by the async operation, if any.
    public func finish(withError error: Error?) {
        if !isCancelled {
            asyncCompletionBlock?(error)
        }
        asyncCompletionBlock = nil
        markDone()
    }
}

// MARK: Private
private extension AsyncOperation {
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
    
    func markStarted() {
        lock {
            updateObservedState(key: \AsyncOperation.isExecuting) {
                _executing = true
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
