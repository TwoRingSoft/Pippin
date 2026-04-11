#if canImport(UIKit)
import UIKit
import CloudKit

/// A UIWindowSceneDelegate that bridges the CloudKit share acceptance callback into
/// NotificationCenter so SwiftUI apps can observe it without a direct delegate reference.
///
/// SwiftUI scene-based apps receive windowScene(_:userDidAcceptCloudKitShareWith:) on the
/// UIWindowSceneDelegate, not UIApplicationDelegate. Wire this up by returning it from
/// application(_:configurationForConnecting:options:) in your UIApplicationDelegate:
///
///     config.delegateClass = CloudKitSceneDelegate.self
///
/// Then observe Notification.Name.cloudKitShareAccepted in your SwiftUI view hierarchy:
///
///     .onReceive(NotificationCenter.default.publisher(for: .cloudKitShareAccepted)) { notification in
///         guard let metadata = notification.userInfo?["metadata"] as? CKShare.Metadata else { return }
///         // handle acceptance
///     }
///
/// Note: @UIApplicationDelegateAdaptor wraps the app delegate in an internal SwiftUI box type,
/// so UIApplication.shared.delegate as? YourAppDelegate always fails at runtime. This
/// NotificationCenter approach avoids that cast entirely.
open class CloudKitSceneDelegate: UIResponder, UIWindowSceneDelegate {
    open func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        NotificationCenter.default.post(
            name: .cloudKitShareAccepted,
            object: nil,
            userInfo: ["metadata": cloudKitShareMetadata]
        )
    }
}

public extension Notification.Name {
    static let cloudKitShareAccepted = Notification.Name("io.tworingsoft.pippin.cloudKitShareAccepted")
}
#endif
