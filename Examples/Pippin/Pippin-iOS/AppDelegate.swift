//
//  AppDelegate.swift
//  PippinTestHarness
//
//  Created by Andrew McKnight on 4/3/17.
//
//

import Pippin
import PippinAdapters
#if DEBUG
import PippinDebugging
#endif
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    lazy var environment: Environment = {
        let environment = Environment.default(
            bugReportRecipients: ["andrew@tworingsoft.com"],
            touchVizRootVC: ViewController(nibName: nil, bundle: nil)
        )

        environment.crashReporter = CrashlyticsAdapter(debug: true)

        #if !targetEnvironment(simulator)
            environment.locator = CoreLocationAdapter(locatorDelegate: self)
        #endif

        #if DEBUG
        environment.model?.debuggingDelegate = self
        environment.debugging = DebugFlowController(databaseFileName: "PippinTestHarnessDatabase")
        #endif

        environment.connectEnvironment()
        
        return environment
    }()

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        environment.debugging?.installViews(appControlPanel: nil)
        #endif
        environment.touchVisualizer?.installViews()
        return true
    }
}

#if DEBUG
extension AppDelegate: ModelDebugging {
    func importFixtures(coreDataController: Model) {
        environment.alerter?.showAlert(title: "Import database fixtures", message: "This is where your app would imports its database from other instances of itself, like on another test device.", type: .info, dismissal: .interactive, occlusion: .weak)
    }

    func exported(coreDataController: Model) {
        environment.alerter?.showAlert(title: "Exporting database", message: "This is where your app would export its database to transport to other instances of itself, like on another test device.", type: .info, dismissal: .interactive, occlusion: .weak)
    }

    func generateTestModels(coreDataController: Model) {
        environment.alerter?.showAlert(title: "Generating test models", message: "This is where your app would generate some test model entities.", type: .info, dismissal: .interactive, occlusion: .strong)
    }

    func deleteModels(coreDataController: Model) {
        environment.alerter?.showAlert(title: "Deleting models", message: "This is where your app would delete its model entities.", type: .info, dismissal: .interactive, occlusion: .strong)
    }
}
#endif

#if !targetEnvironment(simulator)
extension AppDelegate: LocatorDelegate {
    func locator(locator: Locator, updatedToLocation location: Location) {
        environment.logger?.logInfo(message: "locator \(locator) updated to location \(location)")
    }

    func locator(locator: Locator, encounteredError: LocatorError) {
        environment.logger?.logError(message: "Locator \(locator) encountered error \(encounteredError)", error: encounteredError)
    }
}
#endif
