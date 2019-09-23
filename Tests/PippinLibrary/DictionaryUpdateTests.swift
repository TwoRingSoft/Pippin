//
//  DictionaryUpdateTests.swift
//  Pods
//
//  Created by Andrew McKnight on 1/18/19.
//

import XCTest

class DictionaryUpdateTests: XCTestCase {
    
    func testDictionaryUpdate() {
        var dictionary = [0: [1, 2, 3], 2: [2, 4, 6], 3: [3, 6, 9]]
        XCTAssertEqual(dictionary, [0: [1, 2, 3], 2: [2, 4, 6], 3: [3, 6, 9]])
        dictionary.insert(value: [4], forKey: 4) { (current) -> [Int] in
            return current
        }
        XCTAssertEqual(dictionary, [0: [1, 2, 3], 2: [2, 4, 6], 3: [3, 6, 9], 4: [4]])
        dictionary.insert(value: [8], forKey: 4) { (current) -> [Int] in
            return current + [8]
        }
        XCTAssertEqual(dictionary, [0: [1, 2, 3], 2: [2, 4, 6], 3: [3, 6, 9], 4: [4, 8]])
        dictionary.insert(value: [8], forKey: 4) { $0 + [12] }
        XCTAssertEqual(dictionary, [0: [1, 2, 3], 2: [2, 4, 6], 3: [3, 6, 9], 4: [4, 8, 12]])
    }

}
