//
//  shared_utils_ios_tests.swift
//  shared-utils-ios-tests
//
//  Created by Andrew McKnight on 3/4/17.
//
//

import XCTest

class shared_utils_ios_tests: XCTestCase {
    
    func testTribool() {
        let p: [Tribool] = [ false, false, false, nil, nil, nil, true, true, true ]
        let q: [Tribool] = [ false, nil, true, false, nil, true, false, nil, true ]
        let not_p: [Tribool] = [ true, true, true, nil, nil, nil, false, false, false ]
        let p_and_q: [Tribool] = [ false, false, false, false, nil, nil, false, nil, true ]
        let p_or_q: [Tribool] = [ false, nil, true, nil, nil, true, true, true, true]
        let p_implies_q_Kleene: [Tribool] = [ true, true, true, nil, nil, true, false, nil, true]
        let p_implies_q_Łukasiewicz: [Tribool] = [ true, true, true, nil, true, true, false, nil, true ]

        (0 ..< p.count).forEach { i in
            let a = p[i]
            let b = q[i]

            let not_a = !a
            let not_a_expected = not_p[i]
            XCTAssert(not_a == not_a_expected)

            let a_and_b = a && b
            let a_and_b_expected = p_and_q[i]
            XCTAssert(a_and_b == a_and_b_expected)

            let a_or_b = a || b
            let a_or_b_expected = p_or_q[i]
            XCTAssert(a_or_b == a_or_b_expected, "\(a) || \(b): expected \(a_or_b_expected) but got \(a_or_b)")

            let a_implies_b_Kleene = a →* b
            let a_implies_b_Kleene_expected = p_implies_q_Kleene[i]
            XCTAssert(a_implies_b_Kleene == a_implies_b_Kleene_expected, "\(a) ->K \(b): expected \(a_implies_b_Kleene_expected) but got \(a_implies_b_Kleene)")

            let a_implies_b_Łukasiewicz = a →→ b
            let a_implies_b_Łukasiewicz_expected = p_implies_q_Łukasiewicz[i]
            XCTAssert(a_implies_b_Łukasiewicz == a_implies_b_Łukasiewicz_expected, "\(a) ->Ł \(b): expected \(a_implies_b_Łukasiewicz_expected) but got \(a_implies_b_Łukasiewicz)")
        }
    }
    
}
