//
//  Dictionary+JSON.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation

enum DictionaryJSONError: Error {
    case deserializedObjectNotDictionary
}

extension Dictionary where Key == String, Value == Any {

    init(withJSONFromFileAtURL url:URL) throws {
        let data = try Data(contentsOf: url)
        guard let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary else {
            throw DictionaryJSONError.deserializedObjectNotDictionary
        }
        self = dict
    }

}
