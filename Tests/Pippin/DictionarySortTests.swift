//
//  DictionarySortTests.swift
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 1/8/19.
//

import Pippin
import XCTest

class DictionarySortTests: XCTestCase {
    func testSortedKeysByIntValue() {
        let intValuedInput = [
            "d": 6,
            "o": 2,
            "t": 4,
            "r": 3,
            "s": 1,
            "e": 5,
        ]
        
        let expectedAscending = "sorted"
        let computedAscending = intValuedInput.keysSortedByValue().joined()
        XCTAssert(
            expectedAscending == computedAscending,
            "Expected \(expectedAscending) but got \(computedAscending)."
        )
        
        let expectedDescending = "detros"
        let computedDescending = intValuedInput.keysSortedByValue(ascending: false).joined()
        XCTAssert(
            expectedDescending == computedDescending,
            "Expected \(expectedDescending) but got \(computedDescending)."
        )
        
        let expectedAscendingLimited = "sor"
        let computedAscendingLimited = intValuedInput.keysSortedByValue(maxCount: 3).joined()
        XCTAssert(
            expectedAscendingLimited == computedAscendingLimited,
            "Expected \(expectedAscendingLimited) but got \(computedAscendingLimited)."
        )
        
        let expectedDescendingLimited = "det"
        let computedDescendingLimited = intValuedInput.keysSortedByValue(maxCount: 3, ascending: false).joined()
        XCTAssert(
            expectedDescendingLimited == computedDescendingLimited,
            "Expected \(expectedDescendingLimited) but got \(computedDescendingLimited)."
        )
    }
    
    func testSortedKeysByDoubleValue() {
        let doubleValuedInput = [
            "d": 6.0,
            "o": 2.0,
            "t": 4.0,
            "r": 3.0,
            "s": 1.0,
            "e": 5.0,
        ]
        
        let expectedAscending = "sorted"
        let computedAscending = doubleValuedInput.keysSortedByValue(ascending: true).joined()
        XCTAssert(
            expectedAscending == computedAscending,
            "Expected \(expectedAscending) but got \(computedAscending)."
        )
        
        let expectedDescending = "detros"
        let computedDescending = doubleValuedInput.keysSortedByValue(ascending: false).joined()
        XCTAssert(
            expectedDescending == computedDescending,
            "Expected \(expectedDescending) but got \(computedDescending)."
        )
        
        let expectedAscendingLimited = "sor"
        let computedAscendingLimited = doubleValuedInput.keysSortedByValue(maxCount: 3).joined()
        XCTAssert(
            expectedAscendingLimited == computedAscendingLimited,
            "Expected \(expectedAscendingLimited) but got \(computedAscendingLimited)."
        )
        
        let expectedDescendingLimited = "det"
        let computedDescendingLimited = doubleValuedInput.keysSortedByValue(maxCount: 3, ascending: false).joined()
        XCTAssert(
            expectedDescendingLimited == computedDescendingLimited,
            "Expected \(expectedDescendingLimited) but got \(computedDescendingLimited)."
        )
    }
}
