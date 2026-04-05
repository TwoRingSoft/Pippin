#if canImport(UIKit)
import UIKit

public protocol ShakeDelegate: AnyObject {
    func deviceDidShake()
}

public final class ShakeDetector {
    public static weak var delegate: ShakeDelegate?
}

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            ShakeDetector.delegate?.deviceDidShake()
        }
        super.motionEnded(motion, with: event)
    }
}

extension Environment: ShakeDelegate {
    public func deviceDidShake() {
        guard let bugReporter else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        bugReporter.show(fromViewController: rootVC, screenshot: nil, metadata: nil)
    }

    public func enableShakeToBugReport() {
        ShakeDetector.delegate = self
    }
}
#endif
