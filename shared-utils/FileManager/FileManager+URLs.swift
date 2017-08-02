//
//  FileManager+URLs.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Foundation

extension FileManager {

    enum FileManagerURLError: Error {
        case failedToLocateUserDocumentsDirectory
        case failedToConstructURLWithFileName
    }

    class func urlForDocument(named fileName: String) throws -> URL {
        guard let docs = self.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerURLError.failedToLocateUserDocumentsDirectory
        }

        guard let url = (docs as NSURL).appendingPathComponent(fileName) else {
            throw FileManagerURLError.failedToConstructURLWithFileName
        }

        return url
    }

    class func url(forApplicationSupportFile fileName: String) -> URL {
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString
        return URL(fileURLWithPath: applicationSupportDirectory.appendingPathComponent(fileName))

    }

}
