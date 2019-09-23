//
//  XCTestCase+OperationTestHelpers.h
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 11/14/18.
//

@import XCTest;

NS_ASSUME_NONNULL_BEGIN

@class AsyncOperation;

@interface XCTestCase (OperationTestHelpers)

@property (strong, nonatomic) NSOperationQueue *operationQueue;

#pragma mark Top-level Expectation Sets

// sync versions

- (void)addNormalExecutionExpectationsToOperation:(NSOperation *)operation;
- (void)addInFlightCancellationExpectationsToOperation:(NSOperation *)operation;
- (void)addPreflightCancellationExpectationsToOperation:(NSOperation *)operation;

// async versions

- (void)addNormalExecutionExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation;
- (void)addInFlightCancellationExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation;
- (void)addPreflightCancellationExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation;

#pragma mark Execution Procedures

- (void)executeOperations:(NSArray<NSOperation *> *)operations;
- (void)performInFlightCancellationOnOperation:(NSOperation *)operation delay:(NSUInteger)delay;
- (void)performPreflightCancellationOnOperation:(NSOperation *)operation;

#pragma mark Expectation Waiting

- (void)awaitExpectationsWithTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
