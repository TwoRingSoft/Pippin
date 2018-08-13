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

public class CrashlyticsAdapter: NSObject {
    
    init(debug: Bool) {
        Fabric.sharedSDK().debug = debug
        Fabric.with([ Crashlytics.self ])
    }

}

extension CrashlyticsAdapter: CrashReporter {

    public func initializeReporting() {
    }

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

    public func testCrash() {
        Crashlytics.sharedInstance().crash()
    }

}
