//
//  Dictionary+Plist.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/29/18.
//

import Foundation

public typealias PlistRoot = [String: Any]

enum DictionaryPlistError: Error {
    case deserializedObjectNotDictionary
}

public extension Dictionary where Key == String, Value == Any {
    init(withPlistFromFileAtURL url:URL) throws {
        let plistData = try Data(contentsOf: url)
        let options = PropertyListSerialization.ReadOptions(rawValue: 0)
        guard let dict = try PropertyListSerialization.propertyList(from: plistData, options: options, format: nil) as? PlistRoot else {
            throw DictionaryPlistError.deserializedObjectNotDictionary
        }
        self = dict
    }
}
