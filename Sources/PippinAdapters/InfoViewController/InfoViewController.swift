//
//  InfoViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/16/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import Pippin
import SwiftArmcknight
import SwiftArmcknightUIKit
#if canImport(UIKit)
import MessageUI
import UIKit

@objc public protocol InfoViewControllerDelegate {
    @objc optional func inAppPurchasesTapped(inInfoViewController infoViewController: InfoViewController)
    @objc optional func bugReportTapped(inInfoViewController infoViewController: InfoViewController)
}

/**
 A view that shows social network icons with links, web link, acknowledgements,
 copyright info.

 Importantly, provides a secret crash button to test crash reporting in the wild.
 */
public class InfoViewController: UIViewController, AppInfoPresenter {
    fileprivate var environment: Environment
    fileprivate var sharedAssetBundle: Bundle
    public weak var delegate: InfoViewControllerDelegate?
    private var acknowledgements: Acknowledgements
    private var modalPresenter: TransparentModalPresentingViewController?
    private var contactEmails: [String]?
    private let websiteURL: URL
    private let textColor: UIColor
    private weak var logicalParent: UIViewController?

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    /// Create a new `InfoViewController` instance.
    /// - Parameters:
    ///   - acknowledgements: an `Acknowledgements` instance.
    ///   - textColor: color that foreground objects should use.
    ///   - contactEmails: list of email addresses for  contact emails.
    ///   - environment: an `Environment` instance.
    ///   - sharedAssetBundle: bundle for `shared` framework.
    ///   - links: list of `LinkIcon` instances to display.
    ///   - companyLink: a `LinkIcon` to display separately from the others, for the company.
    ///   - logicalParent: the `UIViewController` that is presenting this; not necessarily the direct `parent` of this, which could be a `BlurViewController` or `DismissableModalViewController`.
    public required init(
        acknowledgements: Acknowledgements,
        textColor: UIColor,
        contactEmails: [String]?,
        environment: Environment,
        sharedAssetBundle: Bundle,
        links: [LinkIcon],
        companyLink: LinkIcon,
        logicalParent: UIViewController? = nil
    ) {
        self.websiteURL = companyLink.url
        self.contactEmails = contactEmails
        self.sharedAssetBundle = sharedAssetBundle
        self.environment = environment
        self.acknowledgements = acknowledgements
        self.textColor = textColor
        self.logicalParent = logicalParent
        super.init(nibName: nil, bundle: nil)
        setUpUI(textColor: textColor, links: links, companyLink: companyLink)
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
        openURL(URLString: websiteURL.absoluteString)
    }

    private func pressed(sender: LinkButton) {
        openURL(URLString: sender.url.absoluteString)
    }

    func secretTestCrash() {
        environment.crashReporter?.testCrash()
    }
    
    func reportBugPressed() {
        delegate?.bugReportTapped?(inInfoViewController: self)
    }

    func changelogPressed() {
        guard let contentVC = environment.changelogPresenter?.fullChangelogViewController() else { return }

        let modal = DismissableModalViewController(childViewController: contentVC, titleFont: environment.fonts.title, tintColor: textColor, imageBundle: sharedAssetBundle, insets: UIEdgeInsets.zero.inset(topDelta: 30)) {
            self.modalPresenter?.dismissTransparently(animated: true)
        }

        let blur: BlurViewController
        if #available(iOS 13.0, *) {
            blur = BlurViewController(blurredViewController: modal, vibrancyStyle: .label)
        } else {
            blur = BlurViewController(viewController: modal, vibrancy: true)
        }

        let modalPresenter = TransparentModalPresentingViewController(childViewController: blur)

        if let parent = logicalParent {
            parent.addNewChildViewController(newChildViewController: modalPresenter)
        } else {
            addNewChildViewController(newChildViewController: modalPresenter)
        }

        modalPresenter.view.fillSuperview()
        modalPresenter.presentTransparently(animated: true)
        self.modalPresenter = modalPresenter
    }

    func inAppPurchasesPressed() {
        delegate?.inAppPurchasesTapped?(inInfoViewController: self)
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
        textView.textColor = environment.colors.foreground
        textView.fillSafeArea(inViewController: vc)

        let modal = DismissableModalViewController(childViewController: vc, titleFont: environment.fonts.title, tintColor: textColor, imageBundle: sharedAssetBundle, insets: UIEdgeInsets.zero.inset(topDelta: 30)) {
            self.modalPresenter?.dismissTransparently(animated: true)
        }

        let blur: BlurViewController
        if #available(iOS 13.0, *) {
            blur = BlurViewController(blurredViewController: modal, vibrancyStyle: .label)
        } else {
            blur = BlurViewController(viewController: modal, vibrancy: true)
        }

        let modalPresenter = TransparentModalPresentingViewController(childViewController: blur)

        // ideally we can place the new modal directly above this one instead of "inside" it
        if let parent = logicalParent {
            parent.addNewChildViewController(newChildViewController: modalPresenter)
        } else {
            addNewChildViewController(newChildViewController: modalPresenter)
        }

        modalPresenter.view.fillSuperview()
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

    func setUpUI(textColor: UIColor, links: [LinkIcon], companyLink: LinkIcon) {
        let appInfoStack = configureAppInfoStack()
        let detailStack = configureDetails()
        let companyStack = configureStack(links: links, companyLink: companyLink)

        let stack = UIStackView(arrangedSubviews: [appInfoStack, detailStack, companyStack])
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.axis = .vertical
        
        view.addSubview(stack)
        
        stack.centerAnchors == view.centerAnchors
    }
    
    func configureAppInfoStack() -> UIStackView {
        let appNameLabel = PaddedLabel(insets: UIEdgeInsets(top: 4, left: 12, bottom: 12, right: 12))
        appNameLabel.text = environment.appName
        appNameLabel.font = environment.fonts.superhero
        appNameLabel.textColor = textColor
        appNameLabel.textAlignment = .center
        appNameLabel.adjustsFontSizeToFitWidth = true
        appNameLabel.minimumScaleFactor = 0.7

        let appInfoLabel = UILabel.label(withText: "\(environment.semanticVersion) build \(environment.currentBuild)", font: environment.fonts.text, textColor: textColor, alignment: .center)

        let stack = UIStackView(arrangedSubviews: [appNameLabel, appInfoLabel])
        stack.axis = .vertical
        stack.clipsToBounds = false
        return stack
    }
    
    func configureStack(links: [LinkIcon], companyLink: LinkIcon) -> UIStackView {
        let urlButton = UIButton(frame: .zero)
        urlButton.configure(title: websiteURL.absoluteString, tintColor: textColor, font: environment.fonts.text, target: self, selector: #selector(websiteURLPressed))
        
        let socialLinks = configureSocialLinks(links: links)
        let copyright = configureCopyright(companyLink: companyLink)
        
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

    class LinkButton: UIButton {
        public let url: URL
        init(emphasisSuffix: String = "", title: String? = nil, tintColor: UIColor = UIColor.white, target: Any? = nil, selector: Selector? = nil, imageBundle: Bundle? = nil, linkIcon: LinkIcon) {
            self.url = linkIcon.url
            super.init(frame: .zero)
            if let image = linkIcon.image(bundle: imageBundle ?? Bundle.main)?.withRenderingMode(.alwaysTemplate) {
                setImage(image, for: .normal)
                setImage(image, for: .highlighted)
                setImage(image, for: .selected)
            }
            if let selector = selector {
                addTarget(target, action: selector, for: .touchUpInside)
            }
            self.tintColor = tintColor
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func configureSocialLinks(links: [LinkIcon]) -> UIStackView {
        let lightenedColor = textColor.withAlphaComponent(0.6)

        let stack = UIStackView(arrangedSubviews: links.map {
            LinkButton(tintColor: lightenedColor, target: self, selector: #selector(pressed(sender:)), imageBundle: sharedAssetBundle, linkIcon: $0)
        })
        stack.spacing = 20
        stack.distribution = .equalSpacing

        return stack
    }

    func configureCopyright(companyLink: LinkIcon) -> UILabel {
        let copyrightString = "© \(Calendar.current.component(.year, from: Date()))"
        let string = NSMutableAttributedString(string: "\(copyrightString) \(companyLink.name)")

        // insert company logo (if any) and style copyright text to match
        string.addAttributes([NSAttributedString.Key.font: environment.fonts.text], range: NSMakeRange(0, string.length))

        replace(attachmentImage: companyLink, in: string, textColor: textColor)

        let range = NSMakeRange(0, string.length)
        string.addAttributes([NSAttributedString.Key.foregroundColor: textColor], range: range)

        let label = UILabel(frame: .zero)
        label.attributedText = string
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }
    
    func configureDetails() -> UIStackView {
        var detailRows = [UIView]()

        if acknowledgements.containsAcknowledgements() {
            detailRows.append(detailRow(iconName: "info.circle", title: "Acknowledgements", action: #selector(acknowledgementsPressed)))
        }

        if let _ = environment.inAppPurchaseVendor {
            detailRows.append(detailRow(iconName: "creditcard", title: "In App Purchases", action: #selector(inAppPurchasesPressed)))
        }

        if let _ = environment.bugReporter {
            detailRows.append(detailRow(iconName: "ladybug", title: "Report a Bug", action: #selector(reportBugPressed)))
        }

        if let _ = environment.changelogPresenter {
            detailRows.append(detailRow(iconName: "doc.text", title: "Changelog", action: #selector(changelogPressed)))
        }

        if MFMailComposeViewController.canSendMail() {
            detailRows.append(detailRow(iconName: "envelope", title: "Send a Note", action: #selector(contactPressed)))
        }

        let stack = UIStackView(arrangedSubviews: detailRows)
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .leading

        return stack
    }

    func detailRow(iconName: String, title: String, action: Selector) -> UIView {
        let iconWidth: CGFloat = 30
        let config = UIImage.SymbolConfiguration(scale: .large)
        let imageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: config))
        imageView.tintColor = textColor
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true

        let label = UILabel()
        label.text = title
        label.font = environment.fonts.barButtonTitle
        label.textColor = textColor

        let row = UIStackView(arrangedSubviews: [imageView, label])
        row.spacing = 8
        row.alignment = .center

        let tap = UITapGestureRecognizer(target: self, action: action)
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true

        return row
    }

    func replace(attachmentImage: LinkIcon, in attributedString: NSMutableAttributedString, textColor: UIColor) {
        guard let image = attachmentImage.image(bundle: sharedAssetBundle) else { return }
        let attachment = NSTextAttachment()
        let capHeight = environment.fonts.text.capHeight
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: capHeight * image.size.width / image.size.height, height: capHeight))
        attachment.image = image
        let attachmentString = NSAttributedString(attachment: attachment)

        let range = (attributedString.string as NSString).range(of: attachmentImage.name)
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

#endif
