//
//  CompoundOperationTests.m
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 11/14/18.
//

@import Pippin;
@import XCTest;
#import "XCTestCase+OperationTestHelpers.h"

@interface CompoundOperationTests : XCTestCase

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation CompoundOperationTests

- (void)setUp {
    [super setUp];
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
}

- (void)testCompoundCancellationPreFlight {
    NSMutableArray<NSOperation *> *cancelledSuboperations = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        AsyncOperation *subOperation = [[AsyncOperation alloc] init];
        subOperation.name = [NSString stringWithFormat:@"cancelledOperation %i", i];
        [cancelledSuboperations addObject:subOperation];
        [self addPreflightCancellationExpectationsToAsyncOperation:subOperation];
    }
    
    CompoundOperation *cancelledCompoundOperation = [[CompoundOperation alloc] initWithOperations:cancelledSuboperations];
    cancelledCompoundOperation.name = @"cancelled compound operation";
    cancelledCompoundOperation.compoundQueue.maxConcurrentOperationCount = 1;
    [self addPreflightCancellationExpectationsToAsyncOperation:cancelledCompoundOperation];
    [self performPreflightCancellationOnOperation:cancelledCompoundOperation];
    [self awaitExpectationsWithTimeout:1];
}

/*
 the way these tests are set up, the wait on expectations deadlocks with the operation queues in the compound operations. need to rethink how to perform these tests.
 
- (void)testMultipleSerialCompoundOperations {
    NSMutableArray<NSOperation *> *compoundOperations = [NSMutableArray array];
    for(NSUInteger compoundOperationIndex = 0; compoundOperationIndex < 2; compoundOperationIndex++) {
        NSMutableArray<NSOperation *> *subOperations = [NSMutableArray array];
        for(NSUInteger subOperationIndex = 0; subOperationIndex < 2; subOperationIndex++) {
            if (subOperationIndex % 2 == 0) {
                TestAsyncOperation *asyncOperation = [[TestAsyncOperation alloc] initWithInfinite:NO];
                asyncOperation.name = [NSString stringWithFormat:@"async suboperation %lu", (unsigned long)subOperationIndex];
                [self addNormalExecutionExpectationsToAsyncOperation:asyncOperation];
                [subOperations addObject:asyncOperation];
            } else {
                NSOperation *syncOperation = [[NSOperation alloc] init];
                syncOperation.name = [NSString stringWithFormat:@"sync suboperation %lu", (unsigned long)subOperationIndex];
                [self addNormalExecutionExpectationsToOperation:syncOperation];
                [subOperations addObject:syncOperation];
            }
        }
        
        CompoundOperation *compoundOperation = [[CompoundOperation alloc] initWithOperations:subOperations];
        compoundOperation.name = @"compound operation";
        compoundOperation.compoundQueue.maxConcurrentOperationCount = 1;
        [self addNormalExecutionExpectationsToAsyncOperation:compoundOperation];
        [compoundOperations addObject:compoundOperation];
    }
    
    [self executeOperations:compoundOperations];
    [self awaitExpectationsWithTimeout:10];
}

- (void)testCompoundCancellationInFlight {
    NSMutableArray<NSOperation *> *cancelledSuboperations = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        AsyncOperation *subOperation = [[TestAsyncOperation alloc] initWithInfinite:YES];
        subOperation.name = [NSString stringWithFormat:@"cancelledOperation%i", i];
        // the compound operation will be cancelled while the first suboperation is in flight, with the others waiting (preflight)
        if (i == 0) {
            [self addInFlightCancellationExpectationsToAsyncOperation:subOperation];
        } else {
            [self addPreflightCancellationExpectationsToAsyncOperation:subOperation];
        }
        [cancelledSuboperations addObject:subOperation];
    }
    
    NSOperation *operation = [[NSOperation alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"test sync completion exp"];
    operation.completionBlock = ^{
        [exp fulfill];
    };
    [cancelledSuboperations addObject:operation];
    
    CompoundOperation *cancelledCompoundOperation = [[CompoundOperation alloc] initWithOperations:cancelledSuboperations];
    cancelledCompoundOperation.name = @"cancelled compound operation";
    cancelledCompoundOperation.compoundQueue.maxConcurrentOperationCount = 1;
    [self addInFlightCancellationExpectationsToAsyncOperation:cancelledCompoundOperation];
    [self performInFlightCancellationOnOperation:cancelledCompoundOperation delay:1];
    [self awaitExpectationsWithTimeout:2];
}
 
 */

@end
