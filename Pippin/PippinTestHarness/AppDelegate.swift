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
        let environment = Environment()
        environment.crashReporter = CrashlyticsAdapter(debug: true)
        environment.crashReporter?.environment = environment

        environment.logger = XCGLoggerAdapter(name: "PippinTestHarnessLogger", logLevel: .debug)
        environment.logger?.environment = environment

        environment.activityIndicator = JGProgressHUDAdapter()
        environment.activityIndicator?.environment = environment

        #if DEBUG
        environment.debugging = DebugFlowController(databaseFileName: "PippinTestHarnessDatabase", delegate: self)
        environment.debugging?.environment = environment
        #endif

        environment.touchVisualizer = COSTouchVisualizerAdapter(rootViewController: ViewController(nibName: nil, bundle: nil))
        environment.touchVisualizer?.environment = environment

        environment.bugReporter = PinpointKitAdapter(recipients: ["andrew@tworingsoft.com"])
        environment.bugReporter?.environment = environment

        environment.alerter = SwiftMessagesAdapter()
        environment.alerter?.environment = environment

        AuthorizedCLLocationManager.authorizedLocationManager(scope: .whenInUse, completion: { (result) in
            switch result {
            case .success(let locationManager):
                environment.locator = CoreLocationAdapter(authorizedLocationManager: locationManager, locatorDelegate: self)
                environment.locator?.environment = environment
            case .failure(let error):
                fatalError("failed to authorize location manager: \(error)")
            }
        })
        return environment
    }()

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        environment.debugging?.installViews()
        #endif
        environment.touchVisualizer?.installViews()
        return true
    }
}

#if DEBUG
extension AppDelegate: DebugFlowControllerDelegate {
    func exportedDatabaseData() -> Data? {
        environment.alerter?.showAlert(title: "Exporting database", message: "This is where your app would export its database to transport to other instances of itself, liek on another test device.", type: .info, dismissal: .interactive, occlusion: .weak)
        return nil
    }

    func failedToExportDatabase(error: DebugFlowError) {
        environment.alerter?.showAlert(title: "Failed exporting database", message: "Something went wrong.", type: .error, dismissal: .interactive, occlusion: .strong)
    }

    func debugFlowControllerWantsToGenerateTestModels(debugFlowController: Debugging) {
        environment.alerter?.showAlert(title: "Generating test models", message: "This is where your app would generate some test model entities.", type: .info, dismissal: .interactive, occlusion: .strong)
    }

    func debugFlowControllerWantsToDeleteModels(debugFlowController: Debugging) {
        environment.alerter?.showAlert(title: "Deleting models", message: "This is where your app would delete its model entities.", type: .info, dismissal: .interactive, occlusion: .strong)
    }
}
#endif

extension AppDelegate: LocatorDelegate {
    func locator(locator: Locator, updatedToLocation location: Location) {
        environment.logger?.logInfo(message: "locator \(locator) updated to location \(location)")
    }

    func locator(locator: Locator, encounteredError: LocatorError) {
        environment.logger?.logError(message: "Locator \(locator) encountered error \(encounteredError)", error: encounteredError)
    }
}
