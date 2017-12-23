//
//  InfoViewController.swift
//  Pippin
//
//  Created by Andrew McKnight on 1/16/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import UIKit

enum SocialIcon: String {

    case twoRing = "trs-logo"
    case twitter = "twitter-logo"
    case facebook = "facebook-logo"
    case linkedin = "linkedin-logo"
    case github = "github-logo"

    func image() -> UIImage? {
        return imageAsset(withName: rawValue)
    }

    func imageAsset(withName name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: InfoViewController.self), compatibleWith: nil)
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

/**
 A view that shows social network icons with links, web link, acknowledgements,
 copyright info.

 Importantly, provides a secret crash button to test crash reporting in the wild.
 */
public class InfoViewController: UIViewController {

    fileprivate var environment: Environment

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    public required init(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont, textColor: UIColor, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
        setUpUI(thirdPartyKits: thirdPartyKits, acknowledgements: acknowledgements, titleFont: titleFont, textFont: textFont, textColor: textColor)
        setUpSecretCrash()
    }

}

// MARK: Actions
@objc extension InfoViewController {

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

}

private extension InfoViewController {

    func openURL(URLString: String) {
        let url = URL(string: URLString)!
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func setUpUI(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont, textColor: UIColor) {
        let textView = configureTextView(thirdPartyKits: thirdPartyKits, acknowledgements: acknowledgements, titleFont: titleFont, textFont: textFont, textColor: textColor)
        let socialLinks = configureSocialLinks(textColor: textColor)
        let copyright = configureCopyright(textFont: textFont, textColor: textColor)

        view.addSubview(textView)
        view.addSubview(socialLinks)
        view.addSubview(copyright)

        let width = view.bounds.width
        view.addSubview(textView)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let height = textView.attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).height
        let inset = textView.contentInset.top + textView.contentInset.bottom + textView.textContainerInset.top + textView.textContainerInset.bottom
        let paddingDelta: CGFloat = 20 // for some reason the bounding size is not computed quite correctly

        NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.75, constant: 1).isActive = true
        textView.leadingAnchor == view.leadingAnchor
        textView.trailingAnchor == view.trailingAnchor
        textView.heightAnchor == height + inset + paddingDelta

        socialLinks.topAnchor == textView.bottomAnchor
        socialLinks.centerXAnchor == textView.centerXAnchor

        copyright.topAnchor == socialLinks.bottomAnchor + 30
        copyright.centerXAnchor == socialLinks.centerXAnchor
    }

    func configureSocialLinks(textColor: UIColor) -> UIView {
        let twitterButton = UIButton.button(withImageSetName: SocialIcon.twitter.rawValue, tintColor: textColor.withAlphaComponent(0.6), imageBundle: Bundle(for: InfoViewController.self))
        let facebookButton = UIButton.button(withImageSetName: SocialIcon.facebook.rawValue, tintColor: textColor.withAlphaComponent(0.6), imageBundle: Bundle(for: InfoViewController.self))
        let linkedinButton = UIButton.button(withImageSetName: SocialIcon.linkedin.rawValue, tintColor: textColor.withAlphaComponent(0.6), imageBundle: Bundle(for: InfoViewController.self))
        let githubButton = UIButton.button(withImageSetName: SocialIcon.github.rawValue, tintColor: textColor.withAlphaComponent(0.6), imageBundle: Bundle(for: InfoViewController.self))

        twitterButton.addTarget(self, action: #selector(twitterPressed), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(facebookPressed), for: .touchUpInside)
        linkedinButton.addTarget(self, action: #selector(linkedinPressed), for: .touchUpInside)
        githubButton.addTarget(self, action: #selector(githubPressed), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [ githubButton, twitterButton, facebookButton, linkedinButton ])
        stack.spacing = 20

        return stack
    }

    func configureCopyright(textFont: UIFont, textColor: UIColor) -> UILabel {
        let copyrightString = "© 2017"
        let string = NSMutableAttributedString(string: "\(copyrightString) \(SocialIcon.twoRing.rawValue)")

        // insert two ring logo and style copyright text to match
        string.addAttributes([NSAttributedStringKey.font: textFont], range: NSMakeRange(0, string.length))

        replace(attachmentImage: .twoRing, in: string, font: textFont, textColor: textColor)

        let range = NSMakeRange(0, string.length)
        string.addAttributes([NSAttributedStringKey.foregroundColor: textColor], range: range)

        let label = UILabel(frame: .zero)
        label.attributedText = string
        label.textColor = textColor
        label.tintColor = textColor
        return label
    }

    func configureTextView(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont, textColor: UIColor) -> UITextView {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = false
        textView.backgroundColor = nil
        textView.textAlignment = .center
        textView.dataDetectorTypes = .link
        textView.isScrollEnabled = false
        textView.linkTextAttributes = [ NSAttributedStringKey.foregroundColor.rawValue: textColor.withAlphaComponent(0.6), NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue ]

        let version = environment.semanticVersion!
        let build = environment.currentBuild!
        let appNameString = environment.appName!
        let tworingURL = "http://tworingsoft.com"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:
            "\(appNameString)" +
            "\n\n" +
            "version \(version) build \(build)" +
            (acknowledgements != nil ? "\n\n\(acknowledgements!)" : "") +
            (thirdPartyKits != nil ? "\n\n3rd party software used in this app:\n \(thirdPartyKits!.joined(separator: "\n"))" : "") +
            "\n\n\n" +
            "\(tworingURL)"
        )

        // style the title
        let titleRange = (attributedString.string as NSString).range(of: appNameString)
        attributedString.addAttributes([NSAttributedStringKey.font : titleFont], range: titleRange)

        // center everything
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.string.count))

        // set all non-title text to text font
        attributedString.addAttributes([NSAttributedStringKey.font: textFont], range: NSMakeRange(titleRange.location + titleRange.length, attributedString.string.count - titleRange.location - titleRange.length))

        // set the string
        textView.attributedText = attributedString

        return textView
    }

    func replace(attachmentImage: SocialIcon, in attributedString: NSMutableAttributedString, font: UIFont, textColor: UIColor) {
        let attachment = NSTextAttachment()
        let size = attachmentImage.image() != nil ? attachmentImage.image()!.size : .zero
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: font.capHeight * size.width / size.height, height: font.capHeight))
        attachment.image = attachmentImage.image()
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
