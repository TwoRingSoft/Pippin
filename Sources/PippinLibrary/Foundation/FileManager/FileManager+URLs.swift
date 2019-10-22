//
//  FileManager+URLs.swift
//  PippinLibrary
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import Foundation

public extension FileManager {
    enum FileManagerURLError: Error {
        case failedToLocateSearchPath(FileManager.SearchPathDirectory)
    }

    class func url(forDocumentNamed fileName: String) throws -> URL {
        return try url(forFile: fileName, inDirectory: .documentDirectory, domain: .userDomainMask)
    }

    class func url(forTemporaryFileNamed fileName: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    }

    class func url(forApplicationSupportFile fileName: String) throws -> URL {
        return try url(forFile: fileName, inDirectory: .applicationSupportDirectory, domain: .userDomainMask)
    }
}

private extension FileManager {
    class func url(forFile file: String, inDirectory directory: FileManager.SearchPathDirectory, domain: FileManager.SearchPathDomainMask) throws -> URL {
        guard let applicationSupportDirectory = self.default.urls(for: directory, in: domain).first else {
            throw FileManagerURLError.failedToLocateSearchPath(directory)
        }
        return applicationSupportDirectory.appendingPathComponent(file)
    }
}
