//
//  SocialIcon.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/22/18.
//

#if canImport(UIKit)
import UIKit

public enum SocialIcon: String {
    case github = "github-logo"
}

extension SocialIcon: LinkIcon {
    public func image(bundle: Bundle) -> UIImage? {
        return UIImage(named: rawValue, in: bundle, compatibleWith: nil)
    }

    public var url: URL {
        switch self {
        case .github: return URL(string: "https://github.com/armcknight")!
        }
    }

    public var name: String {
        switch self {
        case .github: return "GitHub"
        }
    }
}
#endif
