//
//  NSBundle+PlistValues.swift
//  Pippin
//
//  Created by Andrew McKnight on 2/26/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

enum BundleKey: String {

    case semanticVersion = "CFBundleShortVersionString"
    case buildNumber = "CFBundleVersion"
    case name = "CFBundleName"

}

extension Bundle {

    public func getSemanticVersion(defaultVersion: SemanticVersion = .zero) -> SemanticVersion {
        guard
        let version = infoDictionary?[BundleKey.semanticVersion.rawValue] as? String,
        let versionStruct = SemanticVersion(version)
        else {
            return defaultVersion
        }
        return versionStruct
    }

    public func getBuild(defaultBuild: Build = .zero) -> Build {
        guard
        let build = infoDictionary?[BundleKey.buildNumber.rawValue] as? String,
        let buildStruct = Build(build)
        else {
            return defaultBuild
        }
        return buildStruct
    }

    public func getAppName(defaultName: String = "?") -> String {
        return infoDictionary?[BundleKey.name.rawValue] as? String ?? defaultName
    }

}
