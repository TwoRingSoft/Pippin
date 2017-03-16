//
//  InfoViewController.swift
//  Trigonometry
//
//  Created by Andrew McKnight on 1/16/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Anchorage
import Crashlytics
import UIKit

enum SocialIcon: String {

    case twoRing = "trs-logo"
    case twitter = "twitter-logo"
    case facebook = "facebook-logo"
    case linkedin = "linkedin-logo"

    func image() -> UIImage {
        switch self {
        case .twoRing: return #imageLiteral(resourceName: "trs-logo")
        case .twitter: return #imageLiteral(resourceName: "twitter-logo")
        case .facebook: return #imageLiteral(resourceName: "facebook-logo")
        case .linkedin: return #imageLiteral(resourceName: "linkedin-logo")
        }
    }

    func url() -> String {
        switch self {
        case .twoRing: return "http://tworingsoft.com"
        case .twitter: return "https://twitter.com/tworingsoft"
        case .facebook: return "https://www.facebook.com/tworingsoft"
        case .linkedin: return "https://www.linkedin.com/company/11026810"
        }
    }
    
}

class InfoViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont) {
        super.init(nibName: nil, bundle: nil)
        setUpUI(thirdPartyKits: thirdPartyKits, acknowledgements: acknowledgements, titleFont: titleFont, textFont: textFont)
        setUpSecretCrash()
    }

}

// MARK: Actions
extension InfoViewController {

    func twitterPressed() {
        openURL(URLString: SocialIcon.twitter.url())
    }

    func facebookPressed() {
        openURL(URLString: SocialIcon.facebook.url())
    }

    func linkedinPressed() {
        openURL(URLString: SocialIcon.linkedin.url())
    }

    func secretTestCrash() {
        Crashlytics.sharedInstance().crash()
    }

    private func openURL(URLString: String) {
        let url = URL(string: URLString)!
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}

private extension InfoViewController {

    func setUpUI(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont) {
        view.backgroundColor = UIColor.white

        let textView = configureTextView(thirdPartyKits: thirdPartyKits, acknowledgements: acknowledgements, titleFont: titleFont, textFont: textFont)
        let socialLinks = configureSocialLinks()
        let copyright = configureCopyright(textFont: textFont)

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

    func configureSocialLinks() -> UIView {
        let twitterButton = UIButton.button(withImageSetName: "twitter-logo")
        let facebookButton = UIButton.button(withImageSetName: "facebook-logo")
        let linkedinButton = UIButton.button(withImageSetName: "linkedin-logo")
        let views = [ twitterButton, facebookButton, linkedinButton ]
        views.forEach { $0.tintColor = .lightLightGray }

        twitterButton.addTarget(self, action: #selector(twitterPressed), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(facebookPressed), for: .touchUpInside)
        linkedinButton.addTarget(self, action: #selector(linkedinPressed), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: views)
        stack.spacing = 20

        return stack
    }

    func configureCopyright(textFont: UIFont) -> UILabel {
        let copyrightString = "© 2017"
        let string = NSMutableAttributedString(string: "\(copyrightString) \(SocialIcon.twoRing.rawValue)")

        // insert two ring logo and style copyright text to match
        let copyrightRange = (string.string as NSString).range(of: copyrightString)
        string.addAttributes([NSForegroundColorAttributeName: UIColor.lightGray], range: copyrightRange)
        string.addAttributes([NSFontAttributeName: textFont], range: NSMakeRange(0, string.length))

        replace(attachmentImage: .twoRing, in: string, font: textFont)

        let label = UILabel(frame: .zero)
        label.attributedText = string
        return label
    }

    func configureTextView(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont) -> UITextView {
        let textView = UITextView(frame: CGRect.zero)
        textView.isEditable = false
        textView.backgroundColor = nil
        textView.textAlignment = .center
        textView.dataDetectorTypes = .link
        textView.isScrollEnabled = false
        textView.linkTextAttributes = [ NSForegroundColorAttributeName: UIColor.lightGray, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue ]

        let version = Bundle.getSemanticVersion()
        let build = Bundle.getBuild()
        let appNameString = Bundle.getAppName()
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
        attributedString.addAttributes([NSFontAttributeName : titleFont], range: titleRange)

        // center everything
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, attributedString.string.characters.count))

        // set all non-title text to text font
        attributedString.addAttributes([NSFontAttributeName: textFont], range: NSMakeRange(titleRange.location + titleRange.length, attributedString.string.characters.count - titleRange.location - titleRange.length))

        // set the string
        textView.attributedText = attributedString

        return textView
    }

    func replace(attachmentImage: SocialIcon, in attributedString: NSMutableAttributedString, font: UIFont) {
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: font.capHeight * attachmentImage.image().size.width / attachmentImage.image().size.height, height: font.capHeight))
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
