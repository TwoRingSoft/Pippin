//
//  Array+ConversationalListing.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 4/19/20.
//

import Foundation

public extension Array {
    var conversationalList: String? {
        if count == 0 {
            return nil
        }

        if count == 1 {
            return String(describing: first!)
        }

        if count == 2 {
            return String(describing: first!) + " and " + String(describing: self[1])
        }

        let commaDelimited = Array(self[0..<(count - 2)]).map({ String(describing: $0) })
        let all = commaDelimited + [Array(self[(count - 2)...(count - 1)]).conversationalList!]
        return all.joined(separator: ", ")
    }
}
