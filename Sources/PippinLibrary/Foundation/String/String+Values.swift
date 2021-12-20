//
//  String+Values.swift
//  FastMath
//
//  Created by Andrew McKnight on 12/19/21.
//

import Foundation

public extension String {
    /// Break up a multiline string into an array of each line's string value.
    var lines: [String] {
        return split(separator: "\n").map({String($0)})
    }

    /// Break up a multiline string into a 2D array of all the characters. Thus '"`abc\ndef\nghi`" becomes `[['a', 'b', 'c'],['d', 'e', 'f'], ['g', 'h', 'i']]`.
    var characterGrid: [[String]] {
        return lines.map {
            return $0.map({String($0)})
        }
    }

    /// Break up a multiline string containing integers 0-9 into a 2D array of those single digit integer values. Thus "`12\n34`" becomes `[[1, 2], [3, 4]]` and not `[[12], [34]]`.
    /// - precondition: Only digits 0-9 may appear; spaces or other characters produce undefined behavior, probably resulting in zeros.
    /// - precondition: The same amount of digits should be in eadh row.
    var intGrid: [[Int]] {
        return characterGrid.map { $0.map { String($0).integerValue } }
    }

    /// Given a string with numbers in multiple lines, return an array of those integer values. Thus "`12\n34`" becomes `[12, 34]`.
    var ints: [Int] {
        return lines.map({Int($0)!})
    }

    /// Split a string by a delimiter and convert each element into an integer value.
    func ints(separator: Character) -> [Int] {
        split(separator: separator).map(\.integerValue)
    }

    /// Split a multiline string into strings containing an alphanumeric sequence and a number separated by a space into tuples containing their typed values.
    var stringsAndInts: [(String, Int)] {
        lines.map {
            let parts = $0.split(separator: " ")
            return (String(parts.first!), String(parts.last!).integerValue)
        }
    }
}
