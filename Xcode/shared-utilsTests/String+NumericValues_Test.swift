//
//  String+NumericValues_Test.swift
//  shared-utils-tests
//
//  Created by Andrew McKnight on 3/14/17.
//
//

import XCTest
@testable import SharedUtils

class String_NumericValues_Test: XCTest {

    func testAllDigitStringQueries() {
        XCTAssert("123".isAllDigits())
        [
            "12b",
            "abc",
            "",
            "12.",
            "12.5",
            "12,5",
        ].forEach {
            XCTAssert(!$0.isAllDigits())
        }
    }

}
