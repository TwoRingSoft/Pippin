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

    public init(subpaths: [String]) {
        precondition(subpaths.count > 0)
        precondition(subpaths.filter({ $0.count > 0 }).count > 0)
        self = String(format: "%@.%@", rDNSDomain, subpaths.joined(separator: ".")).lowercased()
    }

    public init(asRDNSForCurrentAppWithSubpaths subpaths: [String]) {
        precondition(subpaths.count > 0)
        precondition(subpaths.filter({ $0.count > 0 }).count > 0)
        self = String(subpaths: [ Bundle.main.getAppName() ] + subpaths)
    }

}
