//
//  Array+PowerSet_Test.swift
//  PippinLibrary-Unit-Tests
//
//  Created by Andrew McKnight on 4/19/20.
//

import PippinLibrary
import XCTest

class Array_PowerSet_Test: XCTestCase {
    func testPowerSet() {
        let cases: [([Int], Set<Set<Int>>)] = [
            (
                [],
                Set([Set.empty])
            ),
            (
                [1],
                Set([Set([]), Set([1])])
            ),
            (
                [1, 2],
                Set([Set([]), Set([1]), Set([2]), Set([1, 2])])
            ),
            (
                [1, 2, 3, 4],
                Set([
                    Set([]),
                    Set([1]),
                    Set([2]),
                    Set([3]),
                    Set([4]),
                    Set([1, 2]),
                    Set([1, 3]),
                    Set([1, 4]),
                    Set([2, 3]),
                    Set([2, 4]),
                    Set([3, 4]),
                    Set([1, 2, 3]),
                    Set([1, 2, 4]),
                    Set([1, 3, 4]),
                    Set([2, 3, 4]),
                    Set([1, 2, 3, 4])
                ])
            ),
            (
                [1, 1],
                Set([Set([]), Set([1]), Set([1]), Set([1, 1])])
            ),
        ]
        cases.forEach { testCase in
            let input = testCase.0
            let a = input.powerSet
            let b = input.powerSetTail

            let expected = testCase.1
            XCTAssertEqual(a, expected)
            XCTAssertEqual(b, expected)
        }
    }

    let input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
    func testPowerSetPerformance() {
        measure {
            _ = input.powerSet
        }
    }

    func testPowerSetTailPerformance() {
        measure {
            _ = input.powerSetTail
        }
    }
}
