//
//  String+rDNS.swift
//  Dough
//
//  Created by Andrew McKnight on 3/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

let rDNSDomain = "com.tworingsoft"

extension String {

    init(asRDNSForApp app: String, domain: String, subpaths: [String]?) {
        self = String(format: "%@.%@.%@%@", rDNSDomain, app, domain, subpaths != nil && subpaths!.count > 0 ? ".".appending(subpaths!.joined(separator: ".")) : "").lowercased()
    }

}
