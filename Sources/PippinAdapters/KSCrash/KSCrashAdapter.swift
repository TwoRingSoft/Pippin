//
//  KSCrashAdapter.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 4/24/22.
//

import Foundation
import KSCrash
import Pippin
import UIKit

public final class KSCrashAdapter: NSObject, EnvironmentallyConscious {
    public var environment: Environment?

    public init(recipients: [String]) {
        let i = KSCrashInstallationEmail.sharedInstance()
        i?.recipients = recipients
        i?.addConditionalAlert(withTitle: "Crash Detected", message: "We detected a possible app crash on your last usage session. Sorry you were interrupted! Please send us the report so we can try to fix the problem.", yesAnswer: "OK, Send", noAnswer: "No thanks")
        i?.install()
        i?.sendAllReports(completion: { _, _, _ in })
    }

    @objc public func testCrash() {
        let a: Any? = nil
        let _ = a!
    }
}

extension KSCrashAdapter: CrashReporter {
    public func log(message: String) {
        let formatter = ISO8601DateFormatter()
        if KSCrash.sharedInstance().userInfo == nil {
            KSCrash.sharedInstance().userInfo = [AnyHashable: Any]()
        }
        if var log = KSCrash.sharedInstance().userInfo["log"] as? Array<String> {
            log.append(formatter.string(from: Date()) + ": " + message)
        } else {
            KSCrash.sharedInstance().userInfo["log"] = [formatter.string(from: Date()) + ": " + message]
        }
    }

    public func recordNonfatalError(error: Error, metadata: [String : Any]?) {
        KSCrash.sharedInstance().reportUserException(String(asRDNSWithSubpaths: [Bundle(for: KSCrashAdapter.self).identifier, "KSCrashAdapter", "recordNonfatalError"]), reason: "Testing recoring a nonfatal error from KSCrash.", language: "Swift", lineOfCode: "0", stackTrace: [], logAllThreads: true, terminateProgram: false)
    }

    public func setSessionMetadata(keysAndValues: [String : Any]) {
        for (key, value) in keysAndValues {
            KSCrash.sharedInstance().userInfo[key] = value
        }
    }
}

extension KSCrashAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let foregroundColor = environment?.colors.foreground ?? UIColor.black
        let titleLabel = UILabel.label(withText: "CrashReporter:", font: environment!.fonts.title, textColor: foregroundColor)
        let button = UIButton(type: .custom)
        button.setTitle("Test crash", for: .normal)
        button.addTarget(self, action: #selector(testCrash), for: .touchUpInside)
        button.setTitleColor(foregroundColor, for: .normal)
        let stack = UIStackView(arrangedSubviews: [titleLabel, button])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }
}
