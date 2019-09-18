//
//  InfoViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/16/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import MessageUI
import UIKit

private let twoRingURL = "http://tworingsoft.com"

@objc public protocol InfoViewControllerDelegate {
    @objc optional func inAppPurchasesTapped(inInfoViewController infoViewController: InfoViewController)
    @objc optional func bugReportTapped(inInfoViewController infoViewController: InfoViewController)
}

/**
 A view that shows social network icons with links, web link, acknowledgements,
 copyright info.

 Importantly, provides a secret crash button to test crash reporting in the wild.
 */
public class InfoViewController: UIViewController {

    fileprivate var environment: Environment
    fileprivate var sharedAssetBundle: Bundle
    fileprivate var delegate: InfoViewControllerDelegate
    private var acknowledgements: Acknowledgements
    private var modalPresenter: TransparentModalPresentingViewController?
    private var contactEmails: [String]?

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    public required init(acknowledgements: Acknowledgements, textColor: UIColor, contactEmails: [String]?, environment: Environment, sharedAssetBundle: Bundle, delegate: InfoViewControllerDelegate) {
        self.contactEmails = contactEmails
        self.sharedAssetBundle = sharedAssetBundle
        self.environment = environment
        self.delegate = delegate
        self.acknowledgements = acknowledgements
        super.init(nibName: nil, bundle: nil)
        setUpUI(textColor: textColor)
        setUpSecretCrash()
    }

}

// MARK: Actions
@objc extension InfoViewController {
    
    func contactPressed() {
        let mailVC = MFMailComposeViewController(nibName: nil, bundle: nil)
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(contactEmails)
        let appInfo = "\(environment.appName) \(environment.semanticVersion) (\(environment.currentBuild))"
        let subject = "\(appInfo) Feedback"
        mailVC.setSubject(subject)
        mailVC.setMessageBody("\n\n\n\(appInfo)", isHTML: false)
        present(mailVC, animated: true)
    }
    
    func websiteURLPressed() {
        openURL(URLString: twoRingURL)
    }

    func twitterPressed() {
        openURL(URLString: SocialIcon.twitter.url())
    }

    func facebookPressed() {
        openURL(URLString: SocialIcon.facebook.url())
    }

    func linkedinPressed() {
        openURL(URLString: SocialIcon.linkedin.url())
    }

    func githubPressed() {
        openURL(URLString: SocialIcon.github.url())
    }

    func secretTestCrash() {
        environment.crashReporter?.testCrash()
    }
    
    func reportBugPressed() {
        delegate.bugReportTapped?(inInfoViewController: self)
    }
    
    func inAppPurchasesPressed() {
        delegate.inAppPurchasesTapped?(inInfoViewController: self)
    }
    
    func acknowledgementsPressed() {
        let textView = UITextView(frame: .zero)
        textView.attributedText = acknowledgements.acknowledgementsString()
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        let vc = UIViewController(nibName: nil, bundle: nil)
        vc.view.addSubview(textView)
        vc.title = "Acknowledgements"
        textView.backgroundColor = .clear
        textView.fillSuperview()
        
        let modal = DismissableModalViewController(childViewController: BlurViewController(viewController: vc), titleFont: environment.fonts.title, tintColor: .black, imageBundle: sharedAssetBundle, insets: UIEdgeInsets.zero.inset(topDelta: 30)) {
            self.modalPresenter?.dismissTransparently(animated: true)
        }
        let modalPresenter = TransparentModalPresentingViewController(childViewController: modal)
        addNewChildViewController(newChildViewController: modalPresenter)
        if #available(iOS 11.0, *) {
            modalPresenter.view.fillSafeArea(inViewController: self)
        } else {
            modalPresenter.view.fillLayoutMargins()
        }
        modalPresenter.presentTransparently(animated: true)
        self.modalPresenter = modalPresenter
    }

}

// MARK: Private
private extension InfoViewController {

    func openURL(URLString: String) {
        let url = URL(string: URLString)!
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey: Any](), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func setUpUI(textColor: UIColor) {
        let appInfoStack = configureAppInfoStack(textColor: textColor)
        let detailStack = configureDetails()
        let twoRingStack = configureTwoRingStack(textColor: textColor)
        
        let stack = UIStackView(arrangedSubviews: [appInfoStack, detailStack, twoRingStack])
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.axis = .vertical
        
        view.addSubview(stack)
        
        stack.centerAnchors == view.centerAnchors
    }
    
    func configureAppInfoStack(textColor: UIColor) -> UIStackView {
        let appNameLabel = UILabel.label(withText: environment.appName, font: environment.fonts.superhero, textColor: textColor, alignment: .center)
        let appInfoLabel = UILabel.label(withText: "\(environment.semanticVersion) build \(environment.currentBuild)", font: environment.fonts.text, textColor: textColor, alignment: .center)
        
        let stack = UIStackView(arrangedSubviews: [appNameLabel, appInfoLabel])
        stack.axis = .vertical
        return stack
    }
    
    func configureTwoRingStack(textColor: UIColor) -> UIStackView {
        let urlButton = UIButton(frame: .zero)
        urlButton.configure(title: twoRingURL, tintColor: textColor, font: environment.fonts.text, target: self, selector: #selector(websiteURLPressed))
        
        let socialLinks = configureSocialLinks(textColor: textColor)
        let copyright = configureCopyright(textColor: textColor)
        
        if #available(iOS 11.0, *) {
            let stack = UIStackView(arrangedSubviews: [urlButton, copyright, socialLinks])
            stack.axis = .vertical
            stack.setCustomSpacing(7, after: copyright)
            return stack
        } else {
            let innerStack = UIStackView(arrangedSubviews: [copyright, socialLinks])
            innerStack.axis = .vertical
            innerStack.spacing = 7
            
            let stack = UIStackView(arrangedSubviews: [urlButton, innerStack])
            stack.axis = .vertical
            return stack
        }
    }

    func configureSocialLinks(textColor: UIColor) -> UIStackView {
        let lightenedColor = textColor.withAlphaComponent(0.6)
        let twitterButton = UIButton.button(withImageSetName: SocialIcon.twitter.rawValue, tintColor: lightenedColor, imageBundle: sharedAssetBundle)
        let facebookButton = UIButton.button(withImageSetName: SocialIcon.facebook.rawValue, tintColor: lightenedColor, imageBundle: sharedAssetBundle)
        let linkedinButton = UIButton.button(withImageSetName: SocialIcon.linkedin.rawValue, tintColor: lightenedColor, imageBundle: sharedAssetBundle)
        let githubButton = UIButton.button(withImageSetName: SocialIcon.github.rawValue, tintColor: lightenedColor, imageBundle: sharedAssetBundle)

        twitterButton.addTarget(self, action: #selector(twitterPressed), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(facebookPressed), for: .touchUpInside)
        linkedinButton.addTarget(self, action: #selector(linkedinPressed), for: .touchUpInside)
        githubButton.addTarget(self, action: #selector(githubPressed), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [ githubButton, twitterButton, facebookButton, linkedinButton ])
        stack.spacing = 20
        stack.distribution = .equalSpacing

        return stack
    }

    func configureCopyright(textColor: UIColor) -> UILabel {
        let copyrightString = "© 2018"
        let string = NSMutableAttributedString(string: "\(copyrightString) \(SocialIcon.twoRing.rawValue)")

        // insert two ring logo and style copyright text to match
        string.addAttributes([NSAttributedString.Key.font: environment.fonts.text], range: NSMakeRange(0, string.length))

        replace(attachmentImage: .twoRing, in: string, textColor: textColor)

        let range = NSMakeRange(0, string.length)
        string.addAttributes([NSAttributedString.Key.foregroundColor: textColor], range: range)

        let label = UILabel(frame: .zero)
        label.attributedText = string
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }
    
    func configureDetails() -> UIStackView {
        var detailItems = [UIButton]()
        
        if acknowledgements.containsAcknowledgements() {
            let acknowledgementsButton = UIButton.button(withImageSetName: "about", emphasisSuffix: "pressed", title: "Acknowledgements", tintColor: .black, font: environment.fonts.barButtonTitle, target: self, selector: #selector(acknowledgementsPressed), imageBundle: sharedAssetBundle)
            detailItems.append(acknowledgementsButton)
        }
        
        if let _ = environment.inAppPurchaseVendor {
            let inAppPurchaseButton = UIButton.button(withImageSetName: "money", emphasisSuffix: "pressed", title: "In App Purchases", tintColor: .black, font: environment.fonts.barButtonTitle, target: self, selector: #selector(inAppPurchasesPressed), imageBundle: sharedAssetBundle)
            detailItems.append(inAppPurchaseButton)
        }
        
        if let _ = environment.bugReporter {
            let bugReportButton = UIButton.button(withImageSetName: "report-bug", emphasisSuffix: "pressed", title: "Report a Bug", tintColor: .black, font: environment.fonts.barButtonTitle, target: self, selector: #selector(reportBugPressed), imageBundle: sharedAssetBundle)
            detailItems.append(bugReportButton)
        }
        
        if MFMailComposeViewController.canSendMail() {
            let contactButton = UIButton.button(withImageSetName: "contact", emphasisSuffix: "pressed", title: "Send a Note", tintColor: .black, font: environment.fonts.barButtonTitle, target: self, selector: #selector(contactPressed), imageBundle: sharedAssetBundle)
            detailItems.append(contactButton)
        }
        
        detailItems.forEach { button in
            button.titleEdgeInsets = UIEdgeInsets.zero.inset(leftDelta: 20, rightDelta: -20)
        }
        
        let stack = UIStackView(arrangedSubviews: detailItems)
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .equalSpacing
        stack.alignment = .leading
        
        return stack
    }

    func replace(attachmentImage: SocialIcon, in attributedString: NSMutableAttributedString, textColor: UIColor) {
        let attachment = NSTextAttachment()
        let size = attachmentImage.image(bundle: sharedAssetBundle) != nil ? attachmentImage.image(bundle: sharedAssetBundle)!.size : .zero
        let capHeight = environment.fonts.text.capHeight
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: capHeight * size.width / size.height, height: capHeight))
        attachment.image = attachmentImage.image(bundle: sharedAssetBundle)
        let attachmentString = NSAttributedString(attachment: attachment)

        let range = (attributedString.string as NSString).range(of: attachmentImage.rawValue)
        attributedString.replaceCharacters(in: range, with: attachmentString)
    }

    func setUpSecretCrash() {
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.bottomAnchor == view.bottomAnchor
        button.trailingAnchor == view.trailingAnchor

        let secretCrashGesture = UITapGestureRecognizer(target: self, action: #selector(secretTestCrash))
        secretCrashGesture.numberOfTapsRequired = 10
        button.addGestureRecognizer(secretCrashGesture)
    }
    
}

// MARK: MFMailComposeViewControllerDelegate
extension InfoViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled, .saved:
            environment.logger?.logInfo(message: String(format: "[%@] User did not complete feedback flow; result: %i", instanceType(self), String(describing: result)))
        case .failed:
            if let error = error {
                environment.logger?.logError(message: String(format: "[%@] Failed to send contact email: %@", instanceType(self), String(describing: error)), error: error)
            }
            environment.alerter?.showAlert(title: "Error", message: "Failed to send the message", type: .error, dismissal: .automatic, occlusion: .weak)
        case .sent:
            environment.alerter?.showAlert(title: "Sent", message: "Thank you for your feedback!", type: .error, dismissal: .automatic, occlusion: .weak)
        @unknown default:
            fatalError("New unexpected MFMailComposeResult: \(result)")
        }
        dismiss(animated: true)
    }
}
