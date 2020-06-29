//
//  String+HTML.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import Foundation

public extension String {

    var paragraph: String {
        return enclose(withTag: "p")
    }

    var bold: String {
        return enclose(withTag: "b")
    }

    var h1: String {
        return enclose(withTag: "h1")
    }

    var h2: String {
        return enclose(withTag: "h2")
    }

    var h3: String {
        return enclose(withTag: "h3")
    }

    var afterPageBreak: String {
        return enclose(withTag: "div", parameters: "style=\"page-break-before: always\"")
    }

    func enclose(withTag tag: String, parameters: String = "") -> String {
        return "<\(tag) \(parameters)>\(self)</\(tag)>"
    }

}
