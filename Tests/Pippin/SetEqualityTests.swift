//
//  SetEqualityTests.swift
//  Pippin-Unit-Tests
//
//  Created by Andrew McKnight on 11/30/18.
//

import XCTest

class SetEqualityTests: XCTestCase {
    func testSetEquality() {
        let a = Set<Int>([1, 2, 3, 4, 5])
        let b = Set<Int>([1, 2, 3, 4, 5])
        let c = Set<Int>([2, 3, 4, 5])
        let d = Set<Int>([])
        let e = Set<Int>([])
        
        XCTAssert(a.containsSameElements(as: b))
        XCTAssert(b.containsSameElements(as: a))
        
        XCTAssertFalse(a.containsSameElements(as: c))
        XCTAssertFalse(c.containsSameElements(as: a))
        
        XCTAssertFalse(a.containsSameElements(as: d))
        XCTAssertFalse(d.containsSameElements(as: a))
        
        XCTAssert(d.containsSameElements(as: e))
        XCTAssert(e.containsSameElements(as: d))
    }
}
