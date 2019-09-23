//
//  CompoundOperation.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/8/18.
//

import Foundation

enum CompoundOperationError: Error {
    case suboperationFailure(String, [Error])
    
    public static let nsErrorDomain = String(asRDNSForCurrentAppWithSubpaths: ["error.domain.compound-operation"])
    
    func nsError() -> NSError {
        switch self {
        case .suboperationFailure(let name, let errors):
            return NSError(domain: CompoundOperationError.nsErrorDomain, code: CompoundOperation.CompoundOperationErrorCodeSuboperationFailed, userInfo: [
                NSLocalizedDescriptionKey: "\(String(describing: name)) had suboperations that completed with errors.",
                String(describing: CompoundOperationErrorUserInfoKey.underlyingErrors): errors,
            ])
        }
    }
}

enum CompoundOperationErrorUserInfoKey: CustomStringConvertible {
    case underlyingErrors
    
    var description: String {
        let name: String
        switch self {
        case .underlyingErrors: name = "underlying-errors"
        }
        return String(asRDNSForCurrentAppWithSubpaths: ["error.user-info-key.compound-operation", name])
    }
}

open class CompoundOperation: AsyncOperation {
    @objc public static let CompoundOperationErrorCodeSuboperationFailed = 1

    static let CompoundOperationCountingQueueLabel = String(asRDNSForCurrentAppWithSubpaths: ["dispatch-queue", "label", "compound-counting-queue"])
    
    @objc public let compoundQueue = OperationQueue()
    var completedOperations = 0
    var errors = [Error]()
    let countingQueue = DispatchQueue(label: CompoundOperationCountingQueueLabel)
    
    var operations: [Operation]?
    
    @objc public override init() {
        super.init()
    }
    
    @objc public init(operations: [Operation]) {
        self.operations = operations
        super.init()
    }
    
    public init(operations: [Operation]? = nil) {
        self.operations = operations
        super.init()
    }
    
    open override func main() {
        guard let operations = operations else {
            attemptCompoundCompletion()
            return
        }
        operations.forEach {
            injectCompoundCompletionInOperation(operation: $0)
            if let async = $0 as? AsyncOperation {
                injectAsyncErrorGatheringInOperation(asyncOperation: async)
            }
        }
        compoundQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    open override func cancel() {
        compoundQueue.cancelAllOperations()
        
        let operationsToCancel = operations?.filter({
            !$0.isExecuting && !$0.isFinished && !compoundQueue.operations.contains($0)
        })
        
        compoundQueue.isSuspended = true
        operationsToCancel?.forEach({
            compoundQueue.addOperation($0)
            $0.cancel()
        })
        compoundQueue.isSuspended = false
        
        super.cancel()

        countingQueue.sync {
            self.attemptCompoundCompletion()
        }
    }
}

private extension CompoundOperation {
    func injectCompoundCompletionInOperation(operation: Operation) {
        let originalCompletion = operation.completionBlock
        let newCompletion = {
            if let originalCompletion = originalCompletion {
                self.countingQueue.sync(execute: originalCompletion)
            }
            self.countingQueue.sync {
                self.completedOperations += 1
                self.attemptCompoundCompletion()
            }
        }
        operation.completionBlock = newCompletion
    }
    
    func injectAsyncErrorGatheringInOperation(asyncOperation: AsyncOperation) {
        let originalCompletion = asyncOperation.asyncCompletionBlock
        let newCompletion: ErrorBlock = { error in
            if let originalCompletion = originalCompletion {
                self.countingQueue.sync {
                    originalCompletion(error)
                }
            }
            self.countingQueue.sync {
                if let error = error {
                    self.errors.append(error)
                }
            }
        }
        asyncOperation.asyncCompletionBlock = newCompletion
    }
    
    func attemptCompoundCompletion() {
        guard let operations = operations else {
            finish(withError: nil)
            return
        }
        
        if isCancelled || completedOperations + errors.count == operations.count {
            var error: Error?
            if !errors.isEmpty {
                error = CompoundOperationError.suboperationFailure(String(describing: name), errors).nsError()
            }
            finish(withError: error)
        }
    }
}
