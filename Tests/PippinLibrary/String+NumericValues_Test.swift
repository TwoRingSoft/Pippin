//
//  String+NumericValues_Test.swift
//  PippinTests
//
//  Created by Andrew McKnight on 3/14/17.
//
//

import XCTest

class String_NumericValues_Test: XCTestCase {

    func testAllDigitStringQueries() {
        // affirmative case
        XCTAssert("123".isAllDigits())

        // negative cases
        [
            "12b",
            "abc",
            "",
            "12.",
            "12.5",
            "12,5",
        ].forEach {
            XCTAssert(!$0.isAllDigits(), "expected \($0) to report not all digits")
        }
    }

}
