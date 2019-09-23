//
//  Data+JSON.swift
//  Pippin
//
//  Created by Andrew McKnight on 11/7/18.
//

import Foundation

public extension Data {
    /// Initialize a `Data` from a JSON object.
    ///
    /// - Parameters:
    ///   - jsonObject: The JSON structure in `Dictionary` form.
    ///   - pretty: `true` to write `Data` for a string that displays pretty-printed JSON, `false` for compact. (Default is `false`.)
    init(jsonObject: JSONRoot, pretty: Bool = false) throws {
        let options = pretty ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        self = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
    }
}
