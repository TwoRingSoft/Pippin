//
//  AppInfoPresenter.swift
//  PippinCore
//
//  Created by Andrew McKnight on 9/22/19.
//

import Foundation

public protocol LinkIcon {
    func image(bundle: Bundle) -> UIImage?
    var url: URL { get }
    var name: String { get }
}

public protocol Acknowledgements {
    func containsAcknowledgements() -> Bool
    func acknowledgementsString() -> NSAttributedString?
}

public protocol AppInfoPresenter {
    init(acknowledgements: Acknowledgements, textColor: UIColor, contactEmails: [String]?, environment: Environment, sharedAssetBundle: Bundle, links: [LinkIcon], companyLink: LinkIcon)
}
