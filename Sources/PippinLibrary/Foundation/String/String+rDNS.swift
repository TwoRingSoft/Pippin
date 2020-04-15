//
//  String+rDNS.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/5/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

private class PippinDummyRDNSBundleSearchClass {}

extension String {
    init(asRDNSForPippinSubpaths subpaths: [String]) {
        precondition(subpaths.count > 0)
        precondition(subpaths.filter({ $0.count > 0 }).count > 0)
        self = String(asRDNSWithSubpaths: [Bundle(for: PippinDummyRDNSBundleSearchClass.self).identifier] + subpaths)
    }
}

public extension String {
    init(asRDNSWithSubpaths subpaths: [String]) {
        precondition(subpaths.count > 0)
        precondition(subpaths.filter({ $0.count > 0 }).count > 0)
        self = subpaths.joined(separator: ".")

    }

    init(asRDNSForCurrentAppWithSubpaths subpaths: [String]) {
        self = String(asRDNSWithSubpaths: [Bundle.main.identifier] + subpaths)
    }
}
