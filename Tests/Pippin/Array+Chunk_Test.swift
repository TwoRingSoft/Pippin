//
//  Array+Chunk_Test.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/17/18.
//

import XCTest

class Array_Chunk_Test: XCTestCase {
    func testChunk() {
        let empty = [[Int]]()
        
        let a = [1, 2, 3, 4, 5]
        
//        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 0), empty)
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 1), [[1], [2], [3], [4], [5]])
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 2), [[1, 2], [3, 4], [5]])
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 3), [[1, 2, 3], [4, 5]])
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 4), [[1, 2, 3, 4], [5]])
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 5), [[1, 2, 3, 4, 5]])
        XCTAssertEqual(a.chunk(intoSubarraysOfSize: 6), [[1, 2, 3, 4, 5]])
        
        let b = [1, 2, 3, 4]
        XCTAssertEqual(b.chunk(intoSubarraysOfSize: 2), [[1, 2], [3, 4]])
        XCTAssertEqual(b.chunk(intoSubarraysOfSize: 4), [[1, 2, 3, 4]])
        
        let c = [Int]()
        XCTAssertEqual(c.chunk(intoSubarraysOfSize: 0), empty)
        XCTAssertEqual(c.chunk(intoSubarraysOfSize: 1), empty)
        XCTAssertEqual(c.chunk(intoSubarraysOfSize: 2), empty)
    }
}
