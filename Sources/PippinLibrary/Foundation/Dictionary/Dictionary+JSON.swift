//
//  Dictionary+JSON.swift
//  Pippin
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

public typealias JSONRoot = [String: Any]

enum DictionaryJSONError: Error {
    case deserializedObjectNotDictionary
}

public extension Dictionary where Key == String, Value == Any {
    init(withJSONFromFileAtURL url:URL) throws {
        let data = try Data(contentsOf: url)
        let options = JSONSerialization.ReadingOptions(rawValue: 0)
        guard let dict = try JSONSerialization.jsonObject(with: data, options: options) as? Dictionary else {
            throw DictionaryJSONError.deserializedObjectNotDictionary
        }
        self = dict
    }
}
