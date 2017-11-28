//
//  String+rDNS.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

let rDNSDomain = "com.tworingsoft"

extension String {

    public init(asRDNSForApp app: String, domain: String, subpaths: [String]? = nil) {
        var subpathString = ""
        if let subpaths = subpaths, subpaths.count > 0 {
            subpathString = ".".appending(subpaths.joined(separator: "."))
        }
        self = String(format: "%@.%@.%@%@", rDNSDomain, app, domain, subpathString).lowercased()
    }

}
