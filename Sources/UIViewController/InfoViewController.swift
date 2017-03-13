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

class InfoViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont) {
        super.init(nibName: nil, bundle: nil)
        configureUI(thirdPartyKits: thirdPartyKits, acknowledgements: acknowledgements, titleFont: titleFont, textFont: textFont)
    }

}

private extension InfoViewController {

    func configureUI(thirdPartyKits: [String]?, acknowledgements: String?, titleFont: UIFont, textFont: UIFont) {

        view.backgroundColor = UIColor.white

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
        let copyrightString = "© 2017"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:
            "\(appNameString)" +
                "\n\n" +
                "version \(version) build \(build)" +
                (acknowledgements != nil ? "\n\n\(acknowledgements!)" : "") +
                (thirdPartyKits != nil ? "\n\n3rd party software used in this app:\n \(thirdPartyKits!.joined(separator: "\n"))" : "") +
                "\n\n" +
                " \(copyrightString) b" + // add one space before because otherwise it doesn't center properly after insert logo image
                "\n\n\n\n" +
            "\(tworingURL)"
        )

        // style the title
        let titleRange = (attributedString.string as NSString).range(of: appNameString)
        attributedString.addAttributes([NSFontAttributeName : titleFont], range: titleRange)

        // insert two ring logo and style copyright text to match
        let copyrightRange = (attributedString.string as NSString).range(of: copyrightString)
        attributedString.addAttributes([NSForegroundColorAttributeName: UIColor.lightGray], range: copyrightRange)

        let twoRingNameRange = NSMakeRange(copyrightRange.location + copyrightRange.length + 1, 1)
        let textAttachment = NSTextAttachment()
        let attachmentImage = UIImage(named: "trs-logo")!
        textAttachment.image = UIImage(cgImage: attachmentImage.cgImage!, scale: attachmentImage.size.height / textFont.lineHeight * UIScreen.main.scale * 1.7, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.replaceCharacters(in: twoRingNameRange, with: attrStringWithImage)

        // center everything
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, attributedString.string.characters.count))

        // set all non-title text to text font
        attributedString.addAttributes([NSFontAttributeName: textFont], range: NSMakeRange(titleRange.location + titleRange.length, attributedString.string.characters.count - titleRange.location - titleRange.length))

        // set the string
        textView.attributedText = attributedString

        let width = view.bounds.width
        view.addSubview(textView)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let height = attributedString.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).height
        let inset = textView.contentInset.top + textView.contentInset.bottom + textView.textContainerInset.top + textView.textContainerInset.bottom
        let paddingDelta: CGFloat = 20 // for some reason the bounding size is not computed quite correctly

        textView.centerYAnchor == view.centerYAnchor
        textView.leadingAnchor == view.leadingAnchor
        textView.trailingAnchor == view.trailingAnchor
        textView.heightAnchor == height + inset + paddingDelta

        setUpSecretCrash()
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

extension InfoViewController {

    func secretTestCrash() {
        Crashlytics.sharedInstance().crash()
    }

}
