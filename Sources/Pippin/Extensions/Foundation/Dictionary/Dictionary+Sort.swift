//
//  Dictionary+Sort.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/7/19.
//

import Foundation

public extension Dictionary where Value: Comparable {
    /// - Parameters:
    ///   - maxCount: if provided, the maximum number of elements to return. Either the top N or bottom N depending on `ascending`.
    ///   - ascending: if `true`, sort items from smallest to largest, if `false`, largest to smallest.
    /// - Returns: An `Array` of keys sorted by their values.
    func keysSortedByValue(maxCount: Int? = nil, ascending: Bool = true) -> [Key] {
        if let maxCount = maxCount {
            guard maxCount > 0 else { return [] }
        }
        guard count > 0 else { return [] }
        
        let sortedKeys: [Key] = self.map({ (keyValuePair) -> Element in
            return (keyValuePair.key, keyValuePair.value)
        }).sorted(by: { (a, b) -> Bool in
            return ascending ? a.1 < b.1 : a.1 > b.1
        }).map({ (tuple) -> Key in
            return tuple.key
        })
        
        guard let maxCount = maxCount, maxCount < count else { return sortedKeys }
        let topValuesToRetain = count < maxCount ? count : maxCount
        return Array(sortedKeys[0..<topValuesToRetain])
    }
}

public extension Dictionary where Key: Comparable {
    /// - Parameters:
    ///   - maxCount: if provided, the maximum number of elements to return. Either the top N or bottom N depending on `ascending`.
    ///   - ascending: if `true`, sort items from smallest to largest; if `false`, largest to smallest.
    /// - Returns: An `Array` of 2-tuples containing the key and value of each element, sorted by key.
    func sortedByKey(maxCount: Int? = nil, ascending: Bool = true) -> [(Key, Value)] {
        if let maxCount = maxCount {
            guard maxCount > 0 else { return [] }
        }
        guard count > 0 else { return [] }
        
        let tuples = sorted { (a, b) -> Bool in
            return ascending ? a.0 < b.0 : a.0 > b.0
        }
        
        guard let maxCount = maxCount, maxCount < count else { return tuples }
        let topValuesToRetain = count < maxCount ? count : maxCount
        return Array(tuples[0..<topValuesToRetain])
    }
}
