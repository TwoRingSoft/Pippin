//
//  CrashReporterController.swift
//  InformedConsent
//
//  Created by Andrew McKnight on 7/15/17.
//  Copyright © 2017 Insight Therapeutics. All rights reserved.
//

import Crashlytics
import Fabric
import Foundation

struct CrashReporterController {

    static func initializeCrashReporting() {
        Fabric.with([Crashlytics.self])
    }

}
