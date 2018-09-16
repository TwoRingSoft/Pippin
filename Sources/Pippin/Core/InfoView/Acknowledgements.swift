//
//  Acknowledgements.swift
//  Pippin
//
//  Created by Andrew McKnight on 8/22/18.
//

import Foundation

public struct Acknowledgements {
    private var customAcknowledgements: String?
    private var cocoaPodsAcknowledgements: String?
    private unowned var environment: Environment
    
    public init(customAcknowledgements: String? = nil, cocoaPodsAcknowledgementsPlistURL: URL? = nil, environment: Environment) {
        self.customAcknowledgements = customAcknowledgements
        self.environment = environment
        
        if let cocoaPodPlistURL = cocoaPodsAcknowledgementsPlistURL {
            do {
                let data = try Data(contentsOf: cocoaPodPlistURL)
                if let plist = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil) as? [String: Any], let acknowledgementsList = plist["PreferenceSpecifiers"] as? [[String: String]] {
                    cocoaPodsAcknowledgements = acknowledgementsList[1..<acknowledgementsList.count].compactMap { ack in
                        guard let name = ack["Title"],
                            let footer = ack["FooterText"],
                            let license = ack["License"] else {
                                return nil
                        }
                        return "\(name) (\(license))\n\(footer)"
                    }.joined(separator: "\n\n")
                }
            } catch {
                environment.logger.logError(message: String(format: "[%@] Failed to decode CocoaPods acknowledgements plist at %@", valueType(self), String(describing: cocoaPodsAcknowledgementsPlistURL)), error: error)
            }
        } else {
            environment.logger.logInfo(message: String(format: "[%@] No CocoaPods acknowledgement plist url provided", valueType(self)))
        }
    }
    
    func containsAcknowledgements() -> Bool {
        return customAcknowledgements != nil || (cocoaPodsAcknowledgements != nil && cocoaPodsAcknowledgements?.count ?? 0 > 0)
    }
    
    func acknowledgementsString() -> NSAttributedString? {
        var strings = [String]()
        var headings = [String]()
        if let customAcknowledgements = customAcknowledgements {
            let heading = "Special thanks"
            strings.append("\(heading):\n\(customAcknowledgements)")
            headings.append(heading)
        }
        if let cocoaPodsAcknowledgements = cocoaPodsAcknowledgements {
            let heading = "CocoaPods libraries"
            strings.append("\(heading):\n\(cocoaPodsAcknowledgements)")
            headings.append(heading)
        }
        let string = strings.joined(separator: "\n\n")
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.setAttributes([NSAttributedStringKey.font: environment.fonts.text], range: NSMakeRange(0, string.count))
        let boldAttribute = [NSAttributedStringKey.font: environment.fonts.subtitle]
        headings.forEach { attributedString.setAttributes(boldAttribute, range: (string as NSString).range(of: $0)) }
        return NSAttributedString(attributedString: attributedString)
    }
}
