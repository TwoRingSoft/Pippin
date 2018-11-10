//
//  SyncOperationTests.m
//  Pippin
//
//  Copyright © 2018 Two Ring Software. All rights reserved.
//
//  This test class checks the behavior of an operation that is cancelled before
//  it begins execution. It observes the operation's isExecuting property and fails
//  the test if that property is ever set to true. The completionBlock should execute,
//  but asyncCompletion should not.

@import Pippin;
@import XCTest;
#import "Pippin_Unit_Tests-Swift.h"
#import "XCTestCase+OperationTestHelpers.h"

@interface SyncOperationTests : XCTestCase

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation SyncOperationTests

- (void)setUp {
    [super setUp];
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
}

#pragma mark - Tests

- (void)testSerialSyncOperations {
    NSMutableArray<NSOperation *> *operations = [NSMutableArray array];
    for (NSUInteger i = 0; i < 3; i++) {
        NSOperation *syncOperation = [[NSOperation alloc] init];
        [self addNormalExecutionExpectationsToOperation:syncOperation];
        [operations addObject:syncOperation];
    }
    [self executeOperations:operations];
    [self awaitExpectationsWithTimeout:1];
}

- (void)testIllegalEnqueuementOfFinishedSynchronousOperations {
    NSOperation *operation = [[NSOperation alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion"];
    operation.completionBlock = ^{
        XCTAssertThrows([self.operationQueue addOperation:operation]);
        [expectation fulfill];
    };
    [self.operationQueue addOperation:operation];
    [self awaitExpectationsWithTimeout:1];
}

- (void)testIllegalEnqueuementOfCancelledSynchronousOperations {
    NSOperation *operation = [[NSOperation alloc] init];
    [self performPreflightCancellationOnOperation:operation];
    XCTAssertThrows([self.operationQueue addOperation:operation]);
}

/**
 Ensure that a synchronous operation cancelled in flight still calls its `completionBlock`.
 */
- (void)testSyncCancellationInFlight {
    NSOperation *infiniteOp = [[TestInfiniteSyncOperation alloc] init];
    [self addInFlightCancellationExpectationsToOperation:infiniteOp];
    [self performInFlightCancellationOnOperation:infiniteOp delay:1];
    [self awaitExpectationsWithTimeout:2];
}

/**
 Ensure that a synchronous operation cancelled before execution begins still calls its `completionBlock`. Place a 3 second sleep operation on the queue in front of the synchronous operation, then cancel the synchronous operation while the sleeper sleeps. When it finishes and the cancelled operation is processed, its `completionBlock` should execute.
 */
- (void)testSyncCancellationPreflight {
    NSOperation *operation = [[TestInfiniteSyncOperation alloc] init];
    [self addPreflightCancellationExpectationsToOperation:operation];
    [self performPreflightCancellationOnOperation:operation];
    [self awaitExpectationsWithTimeout:1];
}

@end
