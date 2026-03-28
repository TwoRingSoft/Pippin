//
//  SocialIcon.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/22/18.
//

#if canImport(UIKit)
import UIKit

public enum SocialIcon: String {
    case twoRing = "trs-logo"
    case twitter = "twitter-logo"
    case facebook = "facebook-logo"
    case linkedin = "linkedin-logo"
    case github = "github-logo"
}

extension SocialIcon: LinkIcon {
    public func image(bundle: Bundle) -> UIImage? {
        return UIImage(named: rawValue, in: bundle, compatibleWith: nil)
    }

    public var url: URL {
        switch self {
        case .twoRing: return URL(string: "https://tworingsoft.com")!
        case .twitter: return URL(string: "https://twitter.com/tworingsoft")!
        case .facebook: return URL(string: "https://www.facebook.com/tworingsoft")!
        case .linkedin: return URL(string: "https://www.linkedin.com/company/11026810")!
        case .github: return URL(string: "https://github.com/tworingsoft")!
        }
    }

    public var name: String {
        switch self {
        case .twoRing: return "Website"
        case .twitter: return "Twitter"
        case .facebook: return "Facebook"
        case .linkedin: return "LinkedIn"
        case .github: return "GitHub"
        }
    }
}
#endif
