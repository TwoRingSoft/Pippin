//
//  CrashlyticsAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/30/17.
//

import Crashlytics
import Fabric
import Foundation
import Pippin
import UIKit

public class CrashlyticsAdapter: NSObject, EnvironmentallyConscious {
    
    public var environment: Environment?
    
    init(debug: Bool) {
        #if DEBUG
        Fabric.sharedSDK().debug = debug
        #endif
        Fabric.with([ Crashlytics.self ])
    }

}

extension CrashlyticsAdapter: CrashReporter {

    public func log(message: String) {
        #if !TEST
            DispatchQueue.main.async {
                withVaList([ message ]) { args in
                    CLSLogv("%@", args)
                }
            }
        #endif
    }

    public func recordNonfatalError(error: Error, metadata: [String: Any]?) {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: metadata)
    }

    public func setSessionMetadata(keysAndValues: [String: Any]) {
        Crashlytics.sharedInstance().setValuesForKeys(keysAndValues)
    }

    @objc public func testCrash() {
        Crashlytics.sharedInstance().crash()
    }

}

extension CrashlyticsAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let titleLabel = UILabel.label(withText: "CrashReporter:", font: environment!.fonts.title, textColor: .black)
        
        let button = UIButton(type: .custom)
        button.setTitle("Test crash", for: .normal)
        button.addTarget(self, action: #selector(testCrash), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, button])
        stack.axis = .vertical
        stack.spacing = 20
        
        return stack
    }
}
