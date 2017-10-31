//
//  CrashlyticsAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 10/30/17.
//

import Crashlytics
import Fabric
import Foundation

public class CrashlyticsAdapter: NSObject {

}

extension CrashlyticsAdapter: CrashReporter {

    public func initializeReporting() {
        Fabric.sharedSDK().debug = true
        Fabric.with([ Crashlytics.self ])
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

}
