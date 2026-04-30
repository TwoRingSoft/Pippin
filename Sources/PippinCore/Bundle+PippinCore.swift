//
//  Bundle+PippinCore.swift
//  Pippin
//
//  Created by Andrew McKnight on 3/28/26.
//

import Foundation

public extension Bundle {
    static var pippinCore: Bundle {
        return .module
    }

    var gitCommitHash: String? {
        let value = infoDictionary?["GIT_COMMIT_HASH"] as? String
        return (value?.isEmpty == false) ? value : nil
    }

    var gitBranch: String? {
        let value = infoDictionary?["GIT_BRANCH"] as? String
        return (value?.isEmpty == false) ? value : nil
    }

    var gitStatusClean: Bool {
        (infoDictionary?["GIT_STATUS_CLEAN"] as? String) == "1"
    }

    /// Tags suitable for passing to a crash reporter, built from git info injected at build time by `inject-git-info`.
    var gitInfoTags: [String: String] {
        var tags: [String: String] = [:]
        if let hash = gitCommitHash {
            tags["git-commit-hash"] = gitStatusClean ? hash : "\(hash)-dirty"
        }
        if let branch = gitBranch {
            tags["git-branch-name"] = branch
        }
        return tags
    }
}
