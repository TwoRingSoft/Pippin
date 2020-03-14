//
//  COSTouchVisualizerAdapter.swift
//  Pippin
//
//  Created by Andrew McKnight on 9/14/18.
//

import COSTouchVisualizer
import Foundation
import Pippin

/// - Note: `COSTouchVisualizer` requires using its `UIWindow` subclass to construct the main view hierarchy, so this class instantiates and maintains a reference to it, and upon calling `installViews()` calls `makeKeyAndVisible()` on it, thus presenting your app as it normally would be in its `UIApplicationDelegate`.
public class COSTouchVisualizerAdapter: NSObject {
    private let window: UIWindow
    public var environment: Environment?
    private var active: Bool = true
    
    public init(rootViewController: UIViewController) {
        let touchWindow = COSTouchVisualizerWindow(frame: UIScreen.main.bounds)
        self.window = touchWindow
        
        super.init()
        
        touchWindow.rootViewController = rootViewController
        touchWindow.touchVisualizerWindowDelegate = self
        touchWindow.stationaryMorphEnabled = false
    }
}

// MARK: TouchVisualization
extension COSTouchVisualizerAdapter: TouchVisualization {
    public func installViews() {
        window.windowLevel = WindowLevel.touchVisualizer.windowLevel()
        window.isHidden = false
    }
}

// MARK: COSTouchVisualizerWindowDelegate
extension COSTouchVisualizerAdapter: COSTouchVisualizerWindowDelegate {
    public func touchVisualizerWindowShouldShowFingertip(_ window: COSTouchVisualizerWindow) -> Bool {
        return active
    }
    
    public func touchVisualizerWindowShouldAlwaysShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
        return active
    }
}

// MARK: Debuggable
extension COSTouchVisualizerAdapter: Debuggable {
    public func debuggingControlPanel() -> UIView {
        let titleLabel = UILabel.label(withText: "Touch Visualizer:", font: environment!.fonts.title, textColor: .black)

        let label = UILabel.label(withText: "Toggle:")
        let toggle = UISwitch(frame: .zero)
        toggle.isOn = active
        toggle.addTarget(self, action:#selector(toggle(sender:)), for: .valueChanged)
        let controlStack = UIStackView(arrangedSubviews: [label, toggle])
        controlStack.spacing = 20

        let stack = UIStackView(arrangedSubviews: [titleLabel, controlStack])
        stack.axis = .vertical
        stack.spacing = 20

        return stack
    }

    @objc private func toggle(sender: UISwitch) {
        active = sender.isOn
    }
}
