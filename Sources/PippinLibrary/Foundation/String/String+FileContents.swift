//
//  String+FileContents.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/28/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation

enum StringContentsOfFileError: Error {
    case noSuchFileInBundle(String, String?, Bundle)
}

public extension String {

    init(contentsOfResource resource: String, withExtension fileExtension: String? = nil, inBundle bundle: Bundle = Bundle.main) throws {
        guard let htmlStartURL = bundle.url(forResource: resource, withExtension: fileExtension) else {
            throw StringContentsOfFileError.noSuchFileInBundle(resource, fileExtension, bundle)
        }

        self = try String(contentsOf: htmlStartURL)
    }

}
