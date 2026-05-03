//
//  Acknowledgements.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/22/18.
//

import Foundation
import Pippin
import SwiftArmcknight
import SwiftArmcknightUIKit

#if canImport(UIKit)
public struct AppAcknowledgements: Acknowledgements {
    private var specialThanks: String?
    private var disclaimer: String?
    private var libraryAcknowledgements: String?
    private unowned var environment: Environment

    public init(specialThanks: String? = nil, disclaimer: String? = nil, acknowledgementsPlistURL: URL? = nil, environment: Environment) {
        self.specialThanks = specialThanks
        self.disclaimer = disclaimer
        self.environment = environment

        if let plistURL = acknowledgementsPlistURL {
            do {
                let data = try Data(contentsOf: plistURL)
                if let plist = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil) as? [String: Any], let acknowledgementsList = plist["PreferenceSpecifiers"] as? [[String: String]] {
                    libraryAcknowledgements = acknowledgementsList[1..<acknowledgementsList.count].compactMap { ack in
                        guard let name = ack["Title"],
                            let footer = ack["FooterText"],
                            let license = ack["License"] else {
                                return nil
                        }
                        return "\(name) (\(license))\n\(footer)"
                    }.joined(separator: "\n\n")
                }
            } catch {
                environment.logger?.logError(message: String(format: "[%@] Failed to decode acknowledgements plist at %@", valueType(self), String(describing: acknowledgementsPlistURL)), error: error)
            }
        }
    }

    public func containsAcknowledgements() -> Bool {
        return specialThanks != nil || disclaimer != nil || (libraryAcknowledgements != nil && libraryAcknowledgements?.count ?? 0 > 0)
    }

    public func acknowledgementsString() -> NSAttributedString? {
        var strings = [String]()
        var headings = [String]()
        if let specialThanks {
            let heading = "Special thanks"
            strings.append("\(heading):\n\(specialThanks)")
            headings.append(heading)
        }
        if let libraryAcknowledgements {
            let heading = "Libraries"
            strings.append("\(heading):\n\(libraryAcknowledgements)")
            headings.append(heading)
        }
        if let disclaimer {
            let heading = "Disclaimer"
            strings.append("\(heading):\n\(disclaimer)")
            headings.append(heading)
        }
        let string = strings.joined(separator: "\n\n")
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.setAttributes([NSAttributedString.Key.font: environment.fonts.text], range: NSMakeRange(0, string.count))
        let boldAttribute = [NSAttributedString.Key.font: environment.fonts.subtitle]
        headings.forEach { attributedString.setAttributes(boldAttribute, range: (string as NSString).range(of: $0)) }
        return NSAttributedString(attributedString: attributedString)
    }
}

#endif
