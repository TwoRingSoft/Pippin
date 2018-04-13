//
//  PinpointKitAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/25/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import PinpointKit
import UIKit

public final class PinpointKitAdapter: NSObject {

    public var logger: Logger?
    public var recipients: [String]?
    fileprivate var pinpointKit: PinpointKit?

    public init(logger: Logger?) {
        super.init()
        self.logger = logger
    }

}

extension PinpointKitAdapter: BugReporter {

    public func show(fromViewController viewController: UIViewController, screenshot: UIImage?, metadata: [String: AnyObject]?, fonts: Fonts?) {
        guard let recipients = recipients else { return }
        var feedbackConfig = FeedbackConfiguration(recipients: recipients)
        feedbackConfig.additionalInformation = metadata
        var config: Configuration
        if let fonts = fonts {
            let appearance = InterfaceCustomization.Appearance(navigationTitleFont: fonts.title, feedbackSendButtonFont: fonts.subtitle, feedbackCancelButtonFont: fonts.subtitle, feedbackEditHintFont: fonts.text, feedbackBackButtonFont: fonts.subtitle, logCollectionPermissionFont: fonts.italic, logFont: fonts.text, editorDoneButtonFont: fonts.subtitle)
            config = Configuration(appearance: appearance, feedbackConfiguration: feedbackConfig)
        } else {
            config = Configuration(feedbackConfiguration: feedbackConfig)
        }
        pinpointKit = PinpointKit(configuration: config)

        if let screenshot = screenshot {
            pinpointKit?.show(from: viewController, screenshot: screenshot)
        } else {
            pinpointKit?.show(from: viewController)
        }
    }

}
