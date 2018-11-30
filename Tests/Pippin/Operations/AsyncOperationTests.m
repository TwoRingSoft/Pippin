//
//  AsyncOperationTests.m
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 11/14/18.
//

@import Pippin;
@import XCTest;
#import "Pippin_Unit_Tests-Swift.h"
#import "XCTestCase+OperationTestHelpers.h"

@interface AsyncOperationTests : XCTestCase

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation AsyncOperationTests

- (void)setUp {
    [super setUp];
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
}

- (void)testMultipleSerialAsyncOperations {
    NSMutableArray<NSOperation *> *operations = [NSMutableArray array];
    for (NSUInteger i = 0; i < 3; i++) {
        TestAsyncOperation *asyncOperation = [[TestAsyncOperation alloc] initWithInfinite:NO];
        [self addNormalExecutionExpectationsToAsyncOperation:asyncOperation];
        [operations addObject:asyncOperation];
    }
    [self executeOperations:operations];
    [self awaitExpectationsWithTimeout:1];
}

- (void)testIllegalEnqueuementOfFinishedAsynchronousOperations {
    TestAsyncOperation *operation = [[TestAsyncOperation alloc] initWithInfinite:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion"];
    operation.completionBlock = ^{
        XCTAssertThrows([self.operationQueue addOperation:operation]);
        [expectation fulfill];
    };
    [self.operationQueue addOperation:operation];
    [self awaitExpectationsWithTimeout:1];
}

- (void)testIllegalEnqueuementOfCancelledAsynchronousOperations {
    TestAsyncOperation *operation = [[TestAsyncOperation alloc] initWithInfinite:YES];
    [self performPreflightCancellationOnOperation:operation];
    XCTAssertThrows([self.operationQueue addOperation:operation]);
}

- (void)testAsyncCancellationInFlight {
    TestAsyncOperation *infiniteOp = [[TestAsyncOperation alloc] initWithInfinite:YES];
    [self addInFlightCancellationExpectationsToAsyncOperation:infiniteOp];
    [self performInFlightCancellationOnOperation:infiniteOp delay:1];
    [self awaitExpectationsWithTimeout:2];
}

- (void)testAsyncCancellationPreFlight {
    TestAsyncOperation *operation = [[TestAsyncOperation alloc] initWithInfinite:YES];
    [self addPreflightCancellationExpectationsToAsyncOperation:operation];
    [self performPreflightCancellationOnOperation:operation];
    [self awaitExpectationsWithTimeout:1];
}

@end