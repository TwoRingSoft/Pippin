//
//  String+CSV.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/8/19.
//

import Foundation

public typealias CSVRow = [String]
public typealias CSV = [CSVRow]

public extension String {
    /// Split a String containing a CSV file's contents and split it into a 2-dimensional array of Strings, representing each row and its column fields.
    var csv: CSV {
        let rowComponents = split(separator: "\r\n").map({ (substring) -> String in
            return String(substring)
        })
        let valueRows = Array(rowComponents[1..<rowComponents.count]) // return all but header row
        let valueRowComponents: [CSVRow] = valueRows.map({ (row) -> [String] in
            let result = Array(row.split(separator: ",")).map({String($0)})
            return result
        })
        return valueRowComponents
    }
}
