//
//  String+HTML.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation

extension String {

    var paragraph: String {
        return enclose(withTag: "p")
    }

    var bold: String {
        return enclose(withTag: "b")
    }

    func enclose(withTag tag: String) -> String {
        return "<\(tag)>\(self)</\(tag)>"
    }

}
