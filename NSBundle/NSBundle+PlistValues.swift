//
//  NSBundle+PlistValues.swift
//  shared-utils
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

let noValueString = "?"

enum BundleKey: String {

    case semanticVersion = "CFBundleShortVersionString"
    case buildNumber = "CFBundleVersion"
    case name = "CFBundleName"

    func getStringValue() -> String {
        return Bundle.getValue(forKey: self.rawValue)
    }

}

extension Bundle {

    class func getSemanticVersion() -> SemanticVersion {
        return SemanticVersion(BundleKey.semanticVersion.getStringValue()) ?? .zero
    }

    class func getBuild() -> Build {
        return Build(BundleKey.buildNumber.getStringValue()) ?? .zero
    }

    class func getAppName() -> String {
        return BundleKey.name.getStringValue()
    }

}

private extension Bundle {

    class func getValue(forKey key: String) -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            print("[%s] could not get infoDictionary from mainBundle", classType(self))
            return noValueString
        }

        guard let version = infoDict[key] as? String else {
            print("[%s] could not get value from bundle dictionary for key %@", classType(self), key)
            return noValueString
        }
        return version
    }

}
