//
//  SocialIcon.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/22/18.
//

import Foundation

enum SocialIcon: String {
    case twoRing = "trs-logo"
    case twitter = "twitter-logo"
    case facebook = "facebook-logo"
    case linkedin = "linkedin-logo"
    case github = "github-logo"
    
    func image(bundle: Bundle) -> UIImage? {
        return UIImage(named: rawValue, in: bundle, compatibleWith: nil)
    }
    
    func url() -> String {
        switch self {
        case .twoRing: return "http://tworingsoft.com"
        case .twitter: return "https://twitter.com/tworingsoft"
        case .facebook: return "https://www.facebook.com/tworingsoft"
        case .linkedin: return "https://www.linkedin.com/company/11026810"
        case .github: return "https://github.com/tworingsoft"
        }
    }
}
