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
    
    public init(customAcknowledgements: String? = nil, cocoaPodsAcknowledgementsPlistURL: URL? = nil, environment: Environment) {
        self.customAcknowledgements = customAcknowledgements
        
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
                    print(String(describing: acknowledgementsList))
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
    
    func acknowledgementsString() -> String? {
        var strings = [String]()
        if let customAcknowledgements = customAcknowledgements {
            strings.append("Special thanks:\n\(customAcknowledgements)")
        }
        if let cocoaPodsAcknowledgements = cocoaPodsAcknowledgements {
            strings.append("CocoaPods libraries:\n\(cocoaPodsAcknowledgements)")
        }
        return strings.joined(separator: "\n\n")
    }
}
