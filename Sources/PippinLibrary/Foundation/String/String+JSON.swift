//
//  String+JSON.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/7/18.
//

import Foundation

public extension String {
    /// Initialize a `String` from a JSON object.
    ///
    /// - Parameters:
    ///   - jsonObject: The JSON structure in `Dictionary` form.
    ///   - pretty: `true` to a string that displays pretty-printed JSON, `false` for compact. (Default is `false`.)
    init?(jsonObject: JSONRoot, pretty: Bool = false) throws {
        let data = try Data(jsonObject: jsonObject, pretty: pretty)
        guard let string = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        self = string
    }
}
