//
//  XCTestCase+OperationTestHelpers.m
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 11/14/18.
//

@import Pippin;
#import "XCTestCase+OperationTestHelpers.h"

@implementation XCTestCase (OperationTestHelpers)

@dynamic operationQueue;

#pragma mark - Public
#pragma mark -

#pragma mark Top-level Expectation Sets

/*
 These three implementations check the type of the parameter to make sure async operations aren't passed into the public API for sync operations. But, we want to do these things for async (on top of the special things for them) so the following three versions prefixed with '_' are provided so these and the async versions can both call through to the shared logic.
 */

- (void)addNormalExecutionExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will miss adding some necessary async-centric expectations. Use -[addNormalExecutionExpectationsToAsyncOperation:] instead");
    [self _addNormalExecutionExpectationsToOperation:operation async:NO];
}

- (void)addInFlightCancellationExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will miss adding some necessary async-centric expectations. Use -[addInFlightCancellationExpectationsToAsyncOperation:] instead");
    [self _addInFlightCancellationExpectationsToOperation:operation async:NO];
}

- (void)addPreflightCancellationExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will miss adding some necessary async-centric expectations. Use -[addPreflightCancellationExpectationsToAsyncOperation:] instead");
    [self _addPreflightCancellationExpectationsToOperation:operation async:NO];
}

/*
 async versions
 */

- (void)addNormalExecutionExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation {
    [self _addNormalExecutionExpectationsToOperation:asyncOperation async:YES];
    [self expectAsyncOperation:asyncOperation toExecuteAsyncCompletionBlock:YES];
}

- (void)addInFlightCancellationExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation {
    [self _addInFlightCancellationExpectationsToOperation:asyncOperation async:YES];
    [self expectAsyncOperation:asyncOperation toExecuteAsyncCompletionBlock:NO];
}

- (void)addPreflightCancellationExpectationsToAsyncOperation:(AsyncOperation *)asyncOperation {
    [self _addPreflightCancellationExpectationsToOperation:asyncOperation async:YES];
    [self expectAsyncOperation:asyncOperation toExecuteAsyncCompletionBlock:NO];
}

#pragma mark Execution Procedures

- (void)executeOperations:(NSArray<NSOperation *> *)operations {
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperations:operations waitUntilFinished:NO];
    self.operationQueue.suspended = NO;
}

- (void)performInFlightCancellationOnOperation:(NSOperation *)operation delay:(NSUInteger)delay {
    NSAssert(delay > 0, @"Cancellation delay must be greater than 0");
    [self.operationQueue addOperation:operation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [operation cancel];
    });
}

- (void)performPreflightCancellationOnOperation:(NSOperation *)operation {
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperation:operation];
    [operation cancel];
    self.operationQueue.suspended = NO;
}

#pragma mark Expectation Waiting

- (void)awaitExpectationsWithTimeout:(NSTimeInterval)timeout {
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        XCTAssertNil(error, @"expectations failed: %@", error.userInfo);
    }];
}

#pragma mark - Private
#pragma mark -

- (void)_addNormalExecutionExpectationsToOperation:(NSOperation *)operation async:(BOOL)async {
    [self expectOperationToExecuteSyncCompletionBlock:operation];
    if (async) {
        NSAssert([[operation class] isSubclassOfClass:[AsyncOperation class]], @"Expected an async operation");
        [self addNormalExecutionKVOExpectationsToAsyncOperation:(AsyncOperation *)operation];
    } else {
        [self addNormalExecutionKVOExpectationsToOperation:operation];
    }
    
}

- (void)_addInFlightCancellationExpectationsToOperation:(NSOperation *)operation async:(BOOL)async {
    [self expectOperationToExecuteSyncCompletionBlock:operation];
    if (async) {
        NSAssert([[operation class] isSubclassOfClass:[AsyncOperation class]], @"Expected an async operation");
        [self addInFlightCancellationKVOExpectationsToAsyncOperation:(AsyncOperation *)operation];
    } else {
        [self addInFlightCancellationKVOExpectationsToOperation:operation];
    }
}

- (void)_addPreflightCancellationExpectationsToOperation:(NSOperation *)operation async:(BOOL)async {
    [self expectOperationToExecuteSyncCompletionBlock:operation];
    if (async) {
        NSAssert([[operation class] isSubclassOfClass:[AsyncOperation class]], @"Expected an async operation");
        [self addPreflightCancellationKVOExpectationsToAsyncOperation:(AsyncOperation *)operation];
    } else {
        [self addPreflightCancellationKVOExpectationsToOperation:operation];
    }
}

#pragma mark KVO Expectations

/*
 Regular `Operation`s send KVO notifications to keypaths for their property getters that are set to the "is..." variant. `AsyncOperation`, for an unknown reason, sends them to the original property names, "executing", "finished" etc. So we have to create expectations for the different variants depending on which type of operation we have.
 */

- (void)addNormalExecutionKVOExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will use the incorrect keypath. Use -[addNormalExecutionKVOExpectationsToAsyncOperation:] instead");
    [self addExecutionKVOExpectationToOperation:operation inverted:NO];
    [self keyValueObservingExpectationForObject:operation keyPath:NSStringFromSelector(@selector(isFinished)) expectedValue:@YES];
}

- (void)addInFlightCancellationKVOExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will use the incorrect keypath. Use -[addInFlightCancellationKVOExpectationsToAsyncOperation:] instead");
    [self addExecutionKVOExpectationToOperation:operation inverted:NO];
    [self addCancellationKVOExpectationToOperation:operation];
}

- (void)addPreflightCancellationKVOExpectationsToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will use the incorrect keypath. Use -[addPreflightCancellationKVOExpectationsToAsyncOperation:] instead");
    [self addExecutionKVOExpectationToOperation:operation inverted:YES];
    [self addCancellationKVOExpectationToOperation:operation];
}

- (void)addExecutionKVOExpectationToOperation:(NSOperation *)operation inverted:(BOOL)inverted {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will use the incorrect keypath. Use -[addExecutionKVOExpectationToAsyncOperation:inverted:] instead");
    [[self keyValueObservingExpectationForObject:operation keyPath:NSStringFromSelector(@selector(isExecuting)) expectedValue:@YES] setInverted:inverted];
}

- (void)addCancellationKVOExpectationToOperation:(NSOperation *)operation {
    NSAssert(![[operation class] isSubclassOfClass:[AsyncOperation class]], @"Supplying this method with an async operation will use the incorrect keypath. Use -[addCancellationKVOExpectationToAsyncOperation:] instead");
    [self keyValueObservingExpectationForObject:operation keyPath:NSStringFromSelector(@selector(isCancelled)) expectedValue:@YES];
}

/*
 async versions
 */

- (void)addNormalExecutionKVOExpectationsToAsyncOperation:(AsyncOperation *)operation {
    [self addExecutionKVOExpectationToAsyncOperation:operation inverted:NO];
    [self keyValueObservingExpectationForObject:operation keyPath:@"finished" expectedValue:@YES];
}

- (void)addInFlightCancellationKVOExpectationsToAsyncOperation:(AsyncOperation *)operation {
    [self addExecutionKVOExpectationToAsyncOperation:operation inverted:NO];
    [self addCancellationKVOExpectationToAsyncOperation:operation];
}

- (void)addPreflightCancellationKVOExpectationsToAsyncOperation:(AsyncOperation *)operation {
    [self addExecutionKVOExpectationToAsyncOperation:operation inverted:YES];
    [self addCancellationKVOExpectationToAsyncOperation:operation];
}

- (void)addExecutionKVOExpectationToAsyncOperation:(AsyncOperation *)operation inverted:(BOOL)inverted {
    [[self keyValueObservingExpectationForObject:operation keyPath:@"executing" expectedValue:@YES] setInverted:inverted];
}

- (void)addCancellationKVOExpectationToAsyncOperation:(AsyncOperation *)operation {
    [self keyValueObservingExpectationForObject:operation keyPath:@"cancelled" expectedValue:@YES];
}

#pragma mark Completion Expectations

- (void)expectOperationToExecuteSyncCompletionBlock:(NSOperation *)operation {
    XCTestExpectation *syncCompletionExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ syncCompletionExpectation", operation.name]];
    operation.completionBlock = ^{
        [syncCompletionExpectation fulfill];
    };
}

- (void)expectAsyncOperation:(AsyncOperation *)operation toExecuteAsyncCompletionBlock:(BOOL)executeAsyncCompletionBlock {
    XCTestExpectation *asyncCompletionExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ asyncCompletionExpectation", operation.name]];
    [asyncCompletionExpectation setInverted:!executeAsyncCompletionBlock];
    NSString *operationName = [operation.name copy];
    operation.asyncCompletionBlock = ^(NSError *error) {
        if (executeAsyncCompletionBlock) {
            XCTAssertNil(error, @"Should not have received error in async completion of %@.", operationName);
        }
        [asyncCompletionExpectation fulfill];
    };
}

@end
