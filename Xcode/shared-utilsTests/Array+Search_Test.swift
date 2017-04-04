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
        let integers = [ 1, 4, 7, 9, 14 ]
        let integerTestCases: [Int: Int?] = [
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
        for (query, expectedIndex) in integerTestCases {
            let computedIndex = integers.binarySearchRecursive(query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be found at index \(String(describing: expectedIndex)) but was reported at \(String(describing: computedIndex))")
        }

        let doubles: [Double] = [ 1, 4, 7, 9, 14 ]
        let doubleTestCases: [Double: Int?] = [
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
        for (query, expectedIndex) in doubleTestCases {
            let computedIndex = doubles.binarySearchRecursive(query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be found at index \(String(describing: expectedIndex)) but was reported at \(String(describing: computedIndex))")
        }
    }

    func testFuzzyBinarySearch() {
        let integers = [ 1, 4, 7, 9, 14 ]
        let integerTestCases: [Int: Int] = [
            -1000: 0,
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
            1000: 4,
            ]
        for (query, expectedIndex) in integerTestCases {
            let computedIndex = integers.fuzzyBinarySearchRecursive(query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be closest to index \(expectedIndex) but was reported at \(computedIndex)")
        }

        let doubles: [Double] = [ 1, 4, 7, 9, 14 ]
        let doubleTestCases: [Double: Int] = [
            -1000: 0,
            1: 0,
            2: 0,
            2.5: 0, // equidistant between 1 and 4, chooses 1
            4: 1,
            5: 1,
            7: 2,
            8: 2, // equidistant from 7 and 9, chooses 7
            9: 3,
            10: 3,
            12: 4,
            14: 4,
            1000: 4,
            ]
        for (query, expectedIndex) in doubleTestCases {
            let computedIndex = doubles.fuzzyBinarySearchRecursive(query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be closest to index \(expectedIndex) but was reported at \(computedIndex)")
        }
    }

    func testFuzzyBinarySearchWithQueryBetweenSplit() {
        let doubles: [Double] = [ 0, 90, 180, 270 ]
        let doubleTestCases: [Double: Int] = [
            117: 1,
            ]
        for (query, expectedIndex) in doubleTestCases {
            let computedIndex = doubles.fuzzyBinarySearchRecursive(query: query)
            XCTAssert(computedIndex == expectedIndex, "expected \(query) to be closest to index \(expectedIndex) but was reported at \(computedIndex)")
        }
    }

}
