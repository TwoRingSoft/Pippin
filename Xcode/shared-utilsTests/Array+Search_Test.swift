//
//  Array+Search_Test.swift
//  shared-utils-tests
//
//  Created by Andrew McKnight on 3/16/17.
//
//

import XCTest
@testable import SharedUtils

class Array_Search_Test: XCTest {

    func testBinarySearch() {
        let array = [ 1, 4, 7, 9, 14 ]
        let testCases: [Int: Int?] = [
            1: 0,
            2: nil,
            4: 1,
            5: nil,
            7: 2,
            8: nil,
            9: 3,
            10: nil,
            12: nil,
            14: 4,
            ]
        for (query, expectedIndex) in testCases {
            let computedIndex = array.binarySearchRecursive(lowIdx: 0, highIdx: array.count - 1, query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be found at index \(expectedIndex) but was reported at \(computedIndex)")
        }
    }

    func testFuzzyBinarySearch() {
        let array = [ 1, 4, 7, 9, 14 ]
        let testCases: [Int: Int] = [
            1: 0,
            2: 0,
            4: 1,
            5: 1,
            7: 2,
            8: 2, // equidistant from 7 and 9, chooses the lesser (7)
            9: 3,
            10: 3,
            12: 4,
            14: 4,
            ]
        for (query, expectedIndex) in testCases {
            let computedIndex = array.fuzzyBinarySearchRecursive(lowIdx: 0, highIdx: array.count - 1, query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be closest to index \(expectedIndex) but was reported at \(computedIndex)")
        }
    }

}
