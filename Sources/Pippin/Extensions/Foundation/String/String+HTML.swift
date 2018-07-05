//
//  String+HTML.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation

public extension String {

    var paragraph: String {
        return enclose(withTag: "p")
    }

    var bold: String {
        return enclose(withTag: "b")
    }

    var afterPageBreak: String {
        return enclose(withTag: "div", parameters: "style=\"page-break-before: always\"")
    }

    func enclose(withTag tag: String, parameters: String = "") -> String {
        return "<\(tag) \(parameters)>\(self)</\(tag)>"
    }

}
